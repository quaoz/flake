{
  lib,
  config,
  ...
}: let
  cfg = config.garden.hardware.bluetooth;
in {
  options.garden.hardware.bluetooth.enable = lib.mkEnableOption "bluetooth support";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;

      # https://github.com/bluez/bluez/blob/master/src/main.conf
      settings = {
        General = {
          Experimental = true;
          JustWorksRepairing = "always";
        };
      };
    };
  };
}
