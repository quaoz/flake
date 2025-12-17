{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # finder replacement (darwin)
  home.packages = with pkgs;
    lib.optionals (pkgs.stdenv.isDarwin && osConfig.garden.profiles.desktop.enable) [
      raycast
    ];
}
