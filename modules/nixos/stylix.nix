{
  pkgs,
  lib,
  config,
  ...
}: {
  stylix = lib.mkIf config.garden.profiles.desktop.enable {
    cursor = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 32;
    };

    icons = {
      enable = true;
      package = pkgs.pop-icon-theme;
      dark = "Pop-Dark";
    };
  };
}
