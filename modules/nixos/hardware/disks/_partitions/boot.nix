{
  lib,
  config,
  ...
}: let
  cfg = config.garden.hardware.disks;
in {
  boot = lib.mkIf cfg.partitions.boot.enable {
    inherit (cfg.partitions.boot) size;
    type = "EF02";
  };
}
