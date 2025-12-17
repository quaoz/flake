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
        {
          name = "AGENIX_REKEY_ADD_TO_GIT";
          value = "true";
        }
      ];

      commands = [
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
          pkgs.attic-client

          # deploying
          pkgs.nh
          inputs'.deploy-rs.packages.deploy-rs

          # secrets
          pkgs.rage
          pkgs.age-plugin-yubikey
          config.agenix-rekey.package
          # the default darwin `stat` doesn't play nice with agenix generate
          pkgs.uutils-coreutils-noprefix

          # formatters
          config.treefmt.build.wrapper
          inputs'.locker.packages.locker
        ]
        ++ (
          # make configured formatters available
          builtins.attrValues config.treefmt.build.programs
        );
    };
  };
}
