{
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  boot = {
    initrd.availableKernelModules = ["sdhci_pci"];
    binfmt.emulatedSystems = ["x86_64-linux"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/23F4-18ED";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  garden = {
    profiles = {
      desktop.enable = true;
      laptop.enable = true;
    };

    system.boot.loader = "systemd-boot";
    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      keyboard.apple = true;

      monitors = {
        eDP-1 = {
          order = 0;
          width = 3456;
          height = 2160;
          scale = 2.0;
          backlightPath = "apple-panel-bl";
        };

        HDMI-A-1 = {
          order = 1;
          width = 3840;
          height = 2160;
          scale = 1.5;
        };
      };
    };
  };
}
