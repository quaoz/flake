{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # torrent client
  home.packages = with pkgs;
    lib.optionals osConfig.garden.profiles.desktop.enable [
      qbittorrent
    ];
}
