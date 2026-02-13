{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.garden.profiles.desktop.enable {
    home.packages = lib.flatten [
      pkgs.ff2mpv-rust
      pkgs.syncplay
      pkgs.yt-dlp
      pkgs.ffmpeg

      (lib.optionals pkgs.stdenv.isDarwin [
        pkgs.iina
      ])

      (lib.optionals pkgs.stdenv.isLinux [
        pkgs.playerctl
      ])
    ];

    programs.mpv = {
      enable = true;

      scripts = with pkgs.mpvScripts;
        [
          autosub
          modernz
          sponsorblock
          thumbfast
          videoclip
        ]
        ++ lib.optionals pkgs.stdenv.isLinux [
          mpris
        ];

      bindings = {
        "Shift+RIGHT" = "frame-step";
        "Shift+LEFT" = "frame-back-step";
      };

      config = {
        osc = "no";
        border = "no";

        save-watch-history = "yes";
        save-position-on-quit = "yes";

        vo = "gpu-next";
        hwdec = "auto";
        profile = "high-quality";

        sub-auto = "fuzzy";
        slang = "eng,en";
        alang = "jpn,jp,ja,en";

        # WATCH: https://github.com/hyprwm/Hyprland/discussions/12829
        #      - https://github.com/mpv-player/mpv/issues/17204
        target-colorspace-hint = "no";
      };
    };
  };
}
