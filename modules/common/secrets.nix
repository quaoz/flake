{
  lib,
  self,
  pkgs,
  config,
  ...
}: let
  inherit (lib.types) pathWith listOf str submodule enum attrsOf bool;
  inherit (config.networking) hostName;
  inherit (config.me) username pubkey;
  inherit (self.lib) mkOpt mkOpt';
  inherit (pkgs.stdenv) isDarwin;

  relativePath = pathWith {
    absolute = false;
    inStore = false;
  };

  storePath = pathWith {
    absolute = true;
    inStore = true;
  };

  otherSecret = listOf (submodule {
    options = {
      path = mkOpt' relativePath "The secrets path relative to `secretsDir`";
      user = mkOpt' str "The secret owner";
      group = mkOpt' str "The secrets group";
      shared = mkOpt bool false "Whether the secret has multiple owners";
    };
  });

  generatedSecret = attrsOf (submodule {
    options = {
      type = mkOpt' (enum (builtins.attrNames config.age.generators)) "The secrets type";
      user = mkOpt' str "The secret owner";
      group = mkOpt' str "The secrets group";
    };
  });

  cfg = config.garden.secrets;
in {
  options.garden.secrets = {
    secretsDir = mkOpt storePath ../../secrets "Path to dir containing secrets";
    root = mkOpt (listOf relativePath) [] "Paths of secrets owned by root relative to `secretsDir`";
    user = mkOpt (listOf relativePath) [] "Paths of secrets owned by ${username} relative to `secretsDir`";
    other = mkOpt otherSecret [] "Secrets not owned by root or ${username}";
    gen = mkOpt generatedSecret {} "Secrets which are generated";
  };

  config = {
    garden.secrets.user = [
      "ssh/github.age"
      "ssh/github-pub.age"
      "ssh/nix-remote-builder.age"
      "ssh/nix-remote-builder-pub.age"
      "services/atuin/password.age"
      "services/atuin/key.age"
    ];

    age =
      {
        rekey = {
          storageMode = "local";

          localStorageDir = cfg.secretsDir + "/.rekeyed/${hostName}";
          generatedSecretsDir = cfg.secretsDir + "/.generated/";

          hostPubkey = config.garden.pubkey;
          masterIdentities = [
            {
              inherit pubkey;
              identity = "/Users/${username}/.ssh/id_ed25519";
            }
          ];
        };

        generators = {
          _oidc-secret = {
            name,
            pkgs,
            deps,
            decrypt,
            ...
          }: let
            realname = lib.removeSuffix "-oidc-secret" name;
            id = builtins.hashString "md5" realname;
            jq = lib.getExe pkgs.jq;
            xh = lib.getExe pkgs.xh;
          in ''
            APIKEY="$(${decrypt} ${lib.escapeShellArg deps.pocket-id-api-key.file})"
            req() {
                ${xh} --body --pretty none "$1" "https://id.${config.garden.domain}/api/$2" "x-api-key:$APIKEY" "''${@:3}"
            }

            client="$(req GET "oidc/clients/${id}" 2>/dev/null)"
            if [[ "$(${jq} 'has("error")' <<<"$client")" == true ]]; then
                req POST "oidc/clients" 'name=${realname}' 'id=${id}' &>/dev/null
            fi

            resp="$(req POST "oidc/clients/${id}/secret")"
            ${jq} -r '.secret' <<<"$resp"
          '';
        };

        identityPaths = [
          (
            if !isDarwin && config.garden.persist.enable
            then "${config.garden.persist.location}/etc/ssh/ssh_host_ed25519_key"
            else "/etc/ssh/ssh_host_ed25519_key"
          )
          "/Users/${username}/.ssh/id_ed25519"
          "/home/${username}/.ssh/id_ed25519"
        ];

        # collect secrets
        secrets = let
          mkSecret = path: owner: group: {shared ? false}: let
            name =
              (
                lib.removeSuffix ".age" path
                |> lib.path.subpath.components
                |> self.lib.sliceFrom (-2)
                |> builtins.concatStringsSep "-"
              )
              + (lib.optionalString shared "-${owner}");
          in {
            "${name}" = {
              inherit owner group;
              rekeyFile = cfg.secretsDir + "/${path}";
            };
          };

          defaultDeps = {
            _oidc-secret = {
              inherit (config.age.secrets) pocket-id-api-key;
            };
          };

          rootgroup = self.lib.ldTernary pkgs "root" "wheel";
          usergroup = self.lib.ldTernary pkgs "wheel" "admin";
        in
          builtins.concatLists [
            (cfg.root |> builtins.map (s: mkSecret s "root" rootgroup {}))
            (cfg.user |> builtins.map (s: mkSecret s username usergroup {}))
            (cfg.other |> builtins.map (s: mkSecret s.path s.user s.group {inherit (s) shared;}))
            [
              (builtins.mapAttrs (
                  _: s: {
                    inherit (s) group;
                    owner = s.user;
                    generator = {
                      script = s.type;
                      dependencies = defaultDeps.${s.type} or [];
                    };
                  }
                )
                cfg.gen)
            ]
          ]
          |> self.lib.safeMerge;
      }
      // self.lib.onlyDarwin pkgs {
        # use an actual directory
        secretsDir = "/private/tmp/agenix";
        secretsMountPoint = "/private/tmp/agenix.d";
      };
  };
}
