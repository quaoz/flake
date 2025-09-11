{config, ...}: let
  ipv4 = "185.55.243.32";
  ipv6 = "2a00:1911:0001:5d6b:a1c9:9c2d:f38d:b80e";
in {
  garden = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyzvtWP5s8yxGRVPSjcE+RiBVXMHV9+iPPxH/kDZPo/";

    profiles.server.enable = true;

    proxy = {
      enable = true;
      domains."${config.garden.domain}" = {
        registrar = "namecheap";
        dnsProvider = "cloudflare";

        ipv4 = {
          enable = true;
          address = ipv4;
        };

        ipv6 = {
          enable = true;
          address = ipv6;
        };
      };
    };

    services = {
      nginx.enable = true;
      headscale.enable = true;
      pocket-id.enable = true;
    };

    persist.enable = true;

    system = {
      boot.loader = "grub";
      networking.wireless.enable = false;
    };

    hardware = {
      cpu = "intel";

      disks = {
        enable = true;
        device = "/dev/vda";
        impermanence.enable = true;
      };

      virtualisation.qemu = {
        enable = true;
      };
    };
  };

  programs.dconf.enable = true;

  boot.initrd.availableKernelModules = ["uhci_hcd"];

  systemd.network.networks."10-eth" = {
    matchConfig.Name = "ens18";
    address = [
      "${ipv4}/24"
      "${ipv6}/48"
    ];
    routes = [
      {Gateway = "185.55.243.1";}
      {Gateway = "2a00:1911:1::1";}
    ];
    linkConfig.RequiredForOnline = "routable";
  };
}
