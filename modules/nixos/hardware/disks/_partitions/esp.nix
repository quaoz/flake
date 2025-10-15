{
  lib,
  self,
  config,
  ...
}: let
  cfg = config.garden.hardware.disks;
in {
  ESP = lib.mkIf cfg.partitions.esp.enable (self.lib.safeMerge [
    {
      type = "EF00";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = [
          "umask=0077"
        ];
      };
    }

    (
      if cfg.partitions.boot.enable
      then {
        inherit (cfg.partitions.esp) size;
      }
      else {
        start = "1M";
        end = cfg.partitions.esp.size;
      }
    )
  ]);
}
