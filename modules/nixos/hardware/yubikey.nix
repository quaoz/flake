{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.garden.hardware.yubikey;
in {
  options.garden.hardware.yubikey.enable = lib.mkEnableOption "yubikey support" // {default = config.garden.profiles.desktop.enable;};

  config = lib.mkIf cfg.enable {
    services = {
      pcscd.enable = true;
      udev.packages = [pkgs.yubikey-personalization];
    };

    environment.systemPackages = [
      pkgs.yubikey-manager
    ];
  };
}
