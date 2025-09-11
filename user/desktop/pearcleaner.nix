{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals (osConfig.garden.profiles.desktop.enable && pkgs.stdenv.isDarwin) [
      pearcleaner
    ];
}
