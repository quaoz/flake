{
  lib,
  config,
  ...
}: let
  cfg = config.garden.system.boot;
in {
  config = lib.mkIf (cfg.loader == "grub") {
    boot.loader.grub = {
      enable = true;
      inherit (cfg.grub) device;

      efiSupport = lib.mkDefault true;
      useOSProber = lib.mkDefault true;
    };
  };
}
