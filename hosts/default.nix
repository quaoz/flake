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

      # agenix-rekey uses flake-parts (we pin it to a newer version) which sets
      # `_class` for nixosModules, as agenix-rekey doesn't provide a darwinModule
      #  we have to override `_class`
      #
      # https://github.com/hercules-ci/flake-parts/blob/2cccadc7357c0ba201788ae99c4dfa90728ef5e0/modules/nixosModules.nix
      setClass = class: let
        recurse = n: v:
          if builtins.isAttrs v
          then builtins.mapAttrs recurse v
          else if n == "imports"
          then builtins.map (recurse null) v
          else if n == "_class"
          then class
          else v;
      in
        recurse null;
    in {
      modules = builtins.concatLists [
        (self.lib.nixFiles ../modules/${class})

        (lib.optionals (class == "nixos") [
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          inputs.agenix-rekey.nixosModules.default
          inputs.ragenix.nixosModules.default
        ])

        (lib.optionals (class == "darwin") [
          inputs.home-manager.darwinModules.home-manager
          inputs.stylix.darwinModules.stylix
          (setClass "darwin" inputs.agenix-rekey.nixosModules.default)
          inputs.ragenix.darwinModules.default
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
