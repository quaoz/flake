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
