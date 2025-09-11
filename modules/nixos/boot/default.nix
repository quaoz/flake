{
  config,
  self,
  lib,
  ...
}: let
  inherit (config.garden.hardware) disks;
  inherit (self.lib) mkOpt;
  inherit (lib) types;

  grubDevice =
    if disks.enable && disks.partitions.boot.enable
    then ""
    else "nodev";
in {
  options.garden.system.boot = {
    loader = mkOpt (types.enum ["grub" "systemd-boot" "none"]) "none" "The bootloader to use";

    grub = {
      device = mkOpt types.str grubDevice "The device to install the boot loader to";
    };
  };
}
