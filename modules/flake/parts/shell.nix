{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = {
    lib,
    pkgs,
    config,
    inputs',
    ...
  }: {
    devshells.default = {
      name = "flake";

      env = [
        {
          name = "DIRENV_LOG_FORMAT";
          value = "-";
        }
      ];

      commands = [
        {
          name = "rekey";
          category = "secrets";
          help = "re-encrypts secrets for hosts that require them";

          command = "${lib.getExe config.agenix-rekey.package} rekey --add-to-git";
        }
        {
          name = "decrypt";
          category = "secrets";
          help = "attempts to decrypt the specified secret";

          command = ''
            if [[ -f "''${1:-}" ]]; then
                file=$1
            else
                if [[ -n "$FLAKE" && -d "$FLAKE/secrets" ]]; then
                    secrets="$FLAKE/secrets"
                else
                    secrets="$(git rev-parse --show-toplevel)/secrets"
                fi

                file=$(${lib.getExe pkgs.gum} file "$secrets")
            fi

            ${lib.getExe pkgs.rage} -d -i ~/.ssh/id_ed25519 "$file"
          '';
        }
        {
          name = "switch";
          category = "deploy";
          help = "builds and activates the system configuration";

          command = "${lib.getExe pkgs.nh} ${self.lib.ldTernary pkgs "os" "darwin"} switch --ask .# \"$@\"";
        }
        {
          name = "gen-iso";
          category = "deploy";
          help = "builds the installer iso";

          command = "nix build -L .#nixosConfigurations.\"\${1:-blume}\".config.system.build.isoImage";
        }
      ];

      packages =
        [
          pkgs.nh
          pkgs.rage

          config.agenix-rekey.package
          config.treefmt.build.wrapper

          inputs'.locker.packages.locker
          inputs'.deploy-rs.packages.deploy-rs
        ]
        ++ (
          # make configured formatters available
          builtins.attrValues config.treefmt.build.programs
        );
    };
  };
}
