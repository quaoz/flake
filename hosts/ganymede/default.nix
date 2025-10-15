{config, ...}: {
  programs.dconf.enable = true;
  boot.initrd.availableKernelModules = ["uhci_hcd"];

  garden = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyzvtWP5s8yxGRVPSjcE+RiBVXMHV9+iPPxH/kDZPo/";

    monitoring.enable = true;
    profiles.server.enable = true;

    services = {
      nginx.enable = true;
      redis.enable = true;
      postgresql.enable = true;

      geoip.enable = true;
      grafana.enable = true;
      prometheus.enable = true;

      atuin.enable = true;
      blocky.enable = true;
      unbound.enable = true;
      headscale.enable = true;
      pocket-id.enable = true;
      vaultwarden.enable = true;

      automx.enable = true;
      radicale.enable = true;
      roundcube.enable = true;
      mailserver = {
        enable = true;
        dns.enable = true;
      };
    };

    persist.enable = true;
    system.boot.loader = "grub";

    hardware = {
      cpu = "intel";
      virtualisation.qemu.enable = true;

      disks = {
        enable = true;
        device = "/dev/vda";
        impermanence.enable = true;
      };
    };

    magic.public = {
      enable = true;
      domains."${config.garden.domain}" = {
        registrar = "namecheap";
        dnsProvider = "cloudflare";
      };
    };

    networking = {
      wireless.enable = false;

      addresses = {
        public = {
          configure = true;
          device = "ens18";

          ipv4 = {
            enable = true;
            prefix = "24";
            address = "185.55.243.32";
            gateway = "185.55.243.1";
          };

          ipv6 = {
            enable = true;
            prefix = "48";
            address = "2a00:1911:0001:5d6b:a1c9:9c2d:f38d:b80e";
            gateway = "2a00:1911:1::1";
          };
        };

        internal = {
          ipv4 = {
            enable = true;
            address = "100.64.0.2";
          };

          ipv6 = {
            enable = true;
            address = "fd7a:115c:a1e0::2";
          };
        };
      };
    };
  };
}
