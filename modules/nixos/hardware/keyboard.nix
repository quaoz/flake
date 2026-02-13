{
  self,
  lib,
  config,
  ...
}: let
  cfg = config.garden.hardware.keyboard;
in {
  options.garden.hardware.keyboard = {
    layout = self.lib.mkOpt (lib.types.enum ["gb" "us"]) "gb" "The keyboard layout to use";
    apple = lib.mkEnableOption "apple keyboard configuration";
  };

  config = {
    # https://wiki.archlinux.org/title/Apple_Keyboard#hid_apple_module_options
    boot.extraModprobeConfig = lib.optionalString cfg.apple ''
      options hid_apple iso_layout=${
        if cfg.layout == "gb"
        then "1"
        else "0"
      }
    '';

    services.xserver.xkb = {
      inherit (cfg) layout;
      variant = lib.optionalString cfg.apple "mac";
    };
  };
}
