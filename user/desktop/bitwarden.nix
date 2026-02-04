{
  lib,
  osConfig,
  pkgs,
  ...
}: {
  # password manager
  home = lib.mkIf osConfig.garden.profiles.desktop.enable {
    packages = with pkgs; [
      bitwarden-desktop
      bitwarden-cli
    ];
  };
}
