{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  programs.mpv = lib.mkIf osConfig.garden.profiles.desktop.enable {
    enable = true;

    scripts = with pkgs.mpvScripts; [
      # autoload
      autosub
      modernz
      mpris
      sponsorblock
      thumbfast
      videoclip
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
}
