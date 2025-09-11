{
  config,
  lib,
  ...
}: let
  cfg = config.garden.hardware.virtualisation;
in {
  config = lib.mkIf cfg.scsi.enable {
    boot.initrd.availableKernelModules = [
      "virtio_scsi"
    ];
  };
}
