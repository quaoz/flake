{self, ...}: {
  flake.overlays.default = _: prev: self.packages.${prev.stdenv.hostPlatform.system} or {};

  perSystem = {pkgs, ...}: let
    packages =
      self.lib.nixFiles ./default.nix
      |> builtins.map (n: let p = pkgs.callPackage n {}; in {${p.pname or p.name} = p;})
      |> builtins.foldl' pkgs.lib.attrsets.unionOfDisjoint {};
  in {
    inherit packages;
  };
}
