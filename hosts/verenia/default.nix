{
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

  garden = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICMOxWr7LsWITmXfclK0QVvYboKsZFYHKoFmvRHVtZWg";

    profiles.server.enable = true;
    services = {
      nginx.enable = true;
    };

    system.boot.loader = "systemd-boot";

    hardware = {
      cpu = "intel";
    };

    networking = {
      wireless.enable = false;

      addresses = {
        internal = {
          ipv4 = {
            enable = true;
            address = "100.64.0.3";
          };

          ipv6 = {
            enable = true;
            address = "fd7a:115c:a1e0::3";
          };
        };
      };
    };
  };
}
