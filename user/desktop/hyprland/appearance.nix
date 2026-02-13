{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = lib.mkIf (osConfig.garden.profiles.desktop.enable && pkgs.stdenv.isLinux) {
    # don't show titles in groupbar
    group.groupbar.render_titles = false;

    misc = {
      # disable logo, splash and wallpapers
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      force_default_wallpaper = 0;
      enable_anr_dialog = false;
    };

    general = {
      gaps_in = 8;
      gaps_out = 8;
    };

    decoration = {
      # round corners
      rounding = 15;

      # window drop shadows
      shadow.enabled = true;

      # window background blur
      blur = {
        enabled = true;
        size = 4;
        passes = 2;

        brightness = 1;
        contrast = 1;
        ignore_opacity = true;

        new_optimizations = true;
        xray = true;
      };
    };
  };
}
