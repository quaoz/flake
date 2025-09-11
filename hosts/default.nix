{
  lib,
  self,
  inputs,
  ...
}: let
  additionalClasses = {
    rpi = "nixos";
  };
in {
  imports = [
    inputs.easy-hosts.flakeModule
  ];

  config.easy-hosts = {
    inherit additionalClasses;

    shared.modules = [
      ../modules/flake/options.nix
    ];

    perClass = rawClass: let
      class = additionalClasses.${rawClass} or rawClass;
    in {
      modules = builtins.concatLists [
        (self.lib.nixFiles ../modules/${class})

        (lib.optionals (class == "nixos") [
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          inputs.agenix-rekey.nixosModules.default
          inputs.agenix.nixosModules.default
        ])

        (lib.optionals (class == "darwin") [
          inputs.home-manager.darwinModules.home-manager
          inputs.stylix.darwinModules.stylix
          inputs.agenix-rekey.nixosModules.default
          inputs.agenix.darwinModules.default
        ])
      ];
    };

    hosts = {
      # keep-sorted start block=yes newline_separated=yes
      blume = {
        class = "iso";
      };

      ganymede = {
        arch = "x86_64";
        class = "nixos";
      };

      nyx = {
        arch = "aarch64";
        class = "darwin";
      };

      verenia = {
        arch = "x86_64";
        class = "nixos";
      };
      # keep-sorted end
    };
  };
}
