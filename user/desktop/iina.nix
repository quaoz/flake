{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  # media player (darwin)
  home.packages = with pkgs;
    lib.optionals (osConfig.garden.profiles.desktop.enable && pkgs.stdenv.isDarwin) [
      iina
    ];
}
