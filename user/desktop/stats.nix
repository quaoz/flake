{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # menu bar system monitor (darwin)
  home.packages = with pkgs;
    lib.optionals (osConfig.garden.profiles.desktop.enable && pkgs.stdenv.isDarwin) [
      stats
    ];
}
