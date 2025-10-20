{
  lib,
  self,
  ...
}: let
  withPrefix = prefix:
    lib.mapAttrs' (
      name: value: {
        name = "${prefix}${name}";
        inherit value;
      }
    );
in {
  perSystem = {
    self',
    system,
    ...
  }: {
    # TODO: disco checks, lib checks, deploy-rs checks?

    # build devshells, packages and system closures as part of checks
    # see: https://github.com/numtide/blueprint/blob/7ecaeb70f63d14a397c73b38f57177894bb795c8/lib/default.nix#L633
    checks = lib.mergeAttrsList [
      (withPrefix "devshell-" self'.devShells)
      (withPrefix "pkgs-" self'.packages)

      (
        lib.filterAttrs (_: x: x.pkgs.stdenv.hostPlatform.system == system) self.nixosConfigurations
        |> lib.mapAttrs (_: x: x.config.system.build.toplevel)
        |> withPrefix "nixos-"
      )

      (
        lib.filterAttrs (_: x: x.pkgs.stdenv.hostPlatform.system == system) self.darwinConfigurations
        |> lib.mapAttrs (_: x: x.config.system.build.toplevel)
        |> withPrefix "darwin-"
      )
    ];
  };
}
