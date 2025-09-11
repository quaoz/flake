{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # discord client
  home.packages = with pkgs;
    lib.optionals osConfig.garden.profiles.desktop.enable [
      vesktop
    ];
}
