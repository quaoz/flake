{
  lib,
  self,
  inputs,
  ...
}: let
  additionalClasses = {
    rpi = "nixos";
    asahi = "nixos";
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
          inputs.ragenix.nixosModules.default
          inputs.agenix-rekey.nixosModules.default
        ])

        (lib.optionals (class == "darwin") [
          inputs.home-manager.darwinModules.home-manager
          inputs.stylix.darwinModules.stylix
          inputs.ragenix.darwinModules.default
          # WATCH: https://github.com/oddlama/agenix-rekey/issues/133
          #      - https://github.com/oddlama/agenix-rekey/pull/142
          (import "${inputs.agenix-rekey}/modules/agenix-rekey.nix" inputs.nixpkgs)
        ])

        (lib.optionals (rawClass == "asahi") [
          inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
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

      tara = {
        arch = "aarch64";
        class = "asahi";
      };

      verenia = {
        arch = "x86_64";
        class = "nixos";
      };
      # keep-sorted end
    };
  };
}
