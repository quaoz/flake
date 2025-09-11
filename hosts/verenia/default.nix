{
  garden = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICMOxWr7LsWITmXfclK0QVvYboKsZFYHKoFmvRHVtZWg";

    profiles.server.enable = true;

    system.boot.loader = "systemd-boot";

    services = {
    };

    hardware = {
      cpu = "intel";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-label/swap";}
  ];
}
