{
  lib,
  self,
  pkgs,
  config,
  ...
}: let
  inherit (lib.types) pathWith listOf str submodule;
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
    };
  });

  cfg = config.garden.secrets;
in {
  options.garden.secrets = {
    secretsDir = mkOpt storePath ../../secrets "Path to dir containing secrets";
    root = mkOpt (listOf relativePath) [] "Paths of secrets owned by root relative to `secretsDir`";
    user = mkOpt (listOf relativePath) [] "Paths of secrets owned by ${username} relative to `secretsDir`";
    other = mkOpt otherSecret [] "Secrets not owned by root or ${username}";
  };

  config = {
    garden.secrets.user = [
      "ssh/github.age"
      "ssh/github-pub.age"
      "ssh/nix-remote-builder.age"
      "ssh/nix-remote-builder-pub.age"
    ];

    age =
      {
        rekey = {
          storageMode = "local";
          localStorageDir = cfg.secretsDir + "/.rekeyed/${hostName}";

          hostPubkey = config.garden.pubkey;
          masterIdentities = [
            {
              inherit pubkey;
              identity = "/Users/${username}/.ssh/id_ed25519";
            }
          ];
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
          mkSecret = path: owner: group: let
            name =
              lib.removeSuffix ".age" path
              |> lib.path.subpath.components
              |> self.lib.sliceFrom (-2)
              |> builtins.concatStringsSep "-";
          in {
            "${name}" = {
              inherit owner group;
              rekeyFile = cfg.secretsDir + "/${path}";
            };
          };

          rootgroup = self.lib.ldTernary pkgs "root" "wheel";
          usergroup = self.lib.ldTernary pkgs "wheel" "admin";
        in
          builtins.concatLists [
            (cfg.root |> builtins.map (s: mkSecret s "root" rootgroup))
            (cfg.user |> builtins.map (s: mkSecret s username usergroup))
            (cfg.other |> builtins.map (s: mkSecret s.path s.user s.group))
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
