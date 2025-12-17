{inputs, ...}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoPrune.enable = true;
    dockerSocket.enable = true;
  };

  imports = [
    inputs.apple-silicon-support.nixosModules.apple-silicon-support
  ];
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
    profiles.desktop.enable = true;

    system = {
      boot.loader = "systemd-boot";
      desktop.environment = "cosmic";
    };
  };
}
