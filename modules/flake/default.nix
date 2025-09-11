{lib, ...}: let
  inherit (import ./lib/imports.nix {inherit lib;}) harvest nixFiles;
in {
  flake.lib = harvest {inherit lib;} ./lib;

  imports =
    [
      ../../hosts
      ../../pkgs
      ./args.nix
      ./options.nix
    ]
    ++ (nixFiles ./parts);
}
