{
  lib,
  self,
  pkgs,
  config,
  ...
}: let
  # TODO: this is lowk a complete mess, might be worth looking into sops or vaultix
  inherit (lib.types) pathWith listOf str submodule bool;
  inherit (config.networking) hostName;
  inherit (config.me) username;
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
      shared = mkOpt bool false "Whether the secret has multiple owners (appends `user` to the name)";
    };
  });

  cfg = config.garden.secrets;
in {
  options.garden.secrets = {
    secretsDir = mkOpt storePath ../../secrets "Path to dir containing secrets";
    intermediary = mkOpt (listOf relativePath) [] "Paths of intermediary secrets relative to `secretsDir`";
    root = mkOpt (listOf relativePath) [] "Paths of secrets owned by root relative to `secretsDir`";
    user = mkOpt (listOf relativePath) [] "Paths of secrets owned by ${username} relative to `secretsDir`";
    other = mkOpt otherSecret [] "Secrets not owned by root or ${username}";
  };

  imports = [(lib.mkAliasOptionModule ["garden" "secrets" "normal"] ["age" "secrets"])];

  config = {
    garden.secrets.user = [
      "ssh/github.age"
      "ssh/github-pub.age"
      "ssh/nix-remote-builder.age"
      "ssh/nix-remote-builder-pub.age"
      "ssh/uni-conf.age"
      "services/atuin/password.age"
      "services/atuin/key.age"
    ];

    age =
      {
        rekey = {
          storageMode = "local";

          localStorageDir = cfg.secretsDir + "/.rekeyed/${hostName}";
          generatedSecretsDir = cfg.secretsDir + "/.generated/";

          hostPubkey = cfg.secretsDir + "/keys/${hostName}/ssh.pub";
          masterIdentities = [
            {
              pubkey = "age1yubikey1qt9lmj673kr7d09da6crfuxruqmpqdkhgssrcqpl944mlfg07jl66j9xwn7";
              identity = cfg.secretsDir + "/keys/yubikey.pub";
            }
          ];
        };

        generators = {
          bcrypt = {
            pkgs,
            deps,
            decrypt,
            ...
          }: ''
            ${lib.getExe pkgs.mkpasswd} -sm bcrypt < <(${decrypt} ${lib.escapeShellArg deps.input.file})
          '';

          rsa = {pkgs, ...}: ''
            ${lib.getExe pkgs.openssl} genrsa -traditional 4096
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
          mkSecret = path: owner: group: {
            shared ? false,
            intermediary ? false,
          }: let
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
              inherit owner group intermediary;
              rekeyFile = cfg.secretsDir + "/secrets/${path}";
            };
          };

          rootgroup = self.lib.ldTernary pkgs "root" "wheel";
          usergroup = self.lib.ldTernary pkgs "wheel" "admin";
        in
          builtins.concatLists [
            (cfg.root |> builtins.map (s: mkSecret s "root" rootgroup {}))
            (cfg.user |> builtins.map (s: mkSecret s username usergroup {}))
            (cfg.intermediary |> builtins.map (s: mkSecret s "root" rootgroup {intermediary = true;}))
            (cfg.other |> builtins.map (s: mkSecret s.path s.user s.group {inherit (s) shared;}))
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
