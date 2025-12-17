{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  # reference manager
  home.packages = with pkgs;
    lib.optionals (pkgs.stdenv.isDarwin && osConfig.garden.profiles.desktop.enable) [
      paperlib
    ];
}
