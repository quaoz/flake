{
  config,
  lib,
  ...
}: let
  cfg = config.garden.system.desktop;
in {
  config = lib.mkIf (cfg.enable && cfg.environment == "cosmic") {
    services = {
      desktopManager.cosmic.enable = true;

      displayManager = {
        defaultSession = "cosmic";
        cosmic-greeter.enable = true;
      };
    };

    security.pam.services.login.enableGnomeKeyring = true;
  };
}
