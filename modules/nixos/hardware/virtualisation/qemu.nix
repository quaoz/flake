{
  config,
  lib,
  ...
}: let
  cfg = config.garden.hardware.virtualisation;
in {
  config = lib.mkIf cfg.qemu.enable {
    services.qemuGuest.enable = cfg.qemu.guestAgent.enable;

    boot.initrd = {
      availableKernelModules = [
        "virtio_net"
        "virtio_pci"
        "virtio_mmio"
        "virtio_blk"
        "9p"
        "9pnet_virtio"
      ];

      kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
        "virtio_gpu"
      ];
    };
  };
}
