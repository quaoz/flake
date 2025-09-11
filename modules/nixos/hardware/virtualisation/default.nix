{
  lib,
  config,
  ...
}: let
  cfg = config.garden.hardware.virtualisation;
in {
  options.garden.hardware.virtualisation = {
    qemu = {
      enable = lib.mkEnableOption "QEMU";
      guestAgent.enable =
        lib.mkEnableOption "QEMU guest agent"
        // {
          default = true;
        };
    };

    scsi.enable = lib.mkEnableOption "Virtio SCSI module";
  };

  config = lib.mkIf cfg.qemu.enable {
    boot.loader.grub = {
      useOSProber = false;
      efiSupport = false;
    };
  };
}
