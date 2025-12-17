{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.garden.system.desktop;
in {
  config = lib.mkIf (cfg.enable && cfg.environment == "gnome") {
    services = {
      desktopManager.gnome.enable = true;

      displayManager = {
        defaultSession = "gnome";
        gdm.enable = true;
      };
    };

    environment.gnome.excludePackages = with pkgs; [
      epiphany
      geary
      gnome-connections
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-tour
      simple-scan
      yelp
    ];

    security.pam.services.login.enableGnomeKeyring = true;
  };
}
