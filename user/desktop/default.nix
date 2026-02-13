{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # common desktop programs
  config = lib.mkIf osConfig.garden.profiles.desktop.enable {
    home.packages = lib.flatten [
      [
        # torrent client
        pkgs.qbittorrent

        # password manager
        pkgs.bitwarden-desktop
        pkgs.bitwarden-cli

        # minecraft launcher
        pkgs.prismlauncher
      ]

      (lib.optionals pkgs.stdenv.isDarwin [
        # menu bar system monitor
        pkgs.stats

        # finder replacement
        pkgs.raycast
      ])

      (lib.optionals pkgs.stdenv.isLinux [
        # brightness manager
        pkgs.brightnessctl

        # clipboard
        pkgs.wl-clipboard-rs

        # screenshots
        pkgs.grim
        pkgs.slurp

        # file manager
        pkgs.cosmic-files

        # bluetooth frontend
        (lib.optionals osConfig.garden.hardware.bluetooth.enable [
          pkgs.overskride
        ])

        # pipewire frontend
        (lib.optionals osConfig.garden.hardware.audio.enable [
          pkgs.pwvucontrol
        ])
      ])
    ];
  };
}
