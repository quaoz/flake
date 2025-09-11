{
  lib,
  config,
  ...
}: let
  cfg = config.garden.hardware.disks;
in {
  swap = lib.mkIf cfg.partitions.swap.enable {
    size = "100%";
    content = {
      type = "swap";
      randomEncryption = true;
      resumeDevice = true;
    };
  };
}
