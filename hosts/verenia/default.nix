{lib, ...}: {
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
    profiles = {
      server.enable = true;
      monitoring.enable = true;
    };

    system.boot.loader = "systemd-boot";
    hardware.cpu = "intel";

    networking = {
      wireless.enable = false;

      addresses.internal = {
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

    services = {
      nginx.enable = true;
      geoip.enable = true;

      # TODO: remove once unfucked
      remote-builder.enable = lib.mkForce false;
    };
  };
}
