{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # minecraft launcher
  home.packages = with pkgs;
    lib.optionals osConfig.garden.profiles.desktop.enable [
      prismlauncher
    ];
}
