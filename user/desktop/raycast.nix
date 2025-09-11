{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # finder replacement (darwin)
  home.packages = with pkgs;
    lib.optionals osConfig.garden.profiles.desktop.enable [
      raycast
    ];
}
