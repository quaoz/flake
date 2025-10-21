{
  self,
  lib,
  ...
}: {
  flake.overlays.default = _: prev: self.packages.${prev.stdenv.hostPlatform.system} or {};

  perSystem = {
    pkgs,
    self',
    ...
  }: let
    packages =
      self.lib.nixFiles ./default.nix
      |> builtins.map (n: let
        p = pkgs.callPackage n {
          inherit
            (self'.packages)
            fail2ban-prometheus-exporter
            ;
        };
      in {
        ${p.pname or p.name} = p;
      })
      |> builtins.foldl' pkgs.lib.attrsets.unionOfDisjoint {};
  in {
    # filter out packages not available on this system
    packages =
      lib.filterAttrs (
        _: p: lib.meta.availableOn pkgs.stdenv.hostPlatform p
      )
      packages;
  };
}
