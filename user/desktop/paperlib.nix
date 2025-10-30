{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  # reference manager
  home.packages = with pkgs;
    lib.optionals (osConfig.garden.profiles.desktop.enable) [
      paperlib
    ];
}
