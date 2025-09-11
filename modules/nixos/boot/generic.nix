{
  pkgs,
  lib,
  ...
}: {
  boot = {
    # use latest kernel
    kernelPackages = lib.mkOverride 500 pkgs.linuxPackages_latest;

    # let installation modify boot variables
    loader.efi.canTouchEfiVariables = true;

    # don't need it
    swraid.enable = lib.mkDefault false;

    initrd = {
      # common kernel modules
      availableKernelModules = [
        # SATA
        "ahci"
        "ata_piix"

        # USB
        "uas"
        "usb_storage"
        "ehci_pci"
        "xhci_pci"

        # SCSI
        "sd_mod"
        "sr_mod"

        # virtio
        "virtio_pci"
      ];

      # enable systemd in initrd
      systemd.enable = true;
    };
  };
}
