{
  lib,
  self,
  config,
  ...
}: let
  inherit (config.age) secrets;
  cfg = config.garden.services.headscale;
in {
  options = {
    services.headscale.settings.dns.extra_records = self.lib.mkOpt (lib.types.listOf (lib.types.submodule {
      options = {
        name = self.lib.mkOpt' lib.types.str "The domain name";
        type = self.lib.mkOpt' (lib.types.enum ["A" "AAAA"]) "The record type";
        value = self.lib.mkOpt' lib.types.str "The record value";
      };
    })) [] "Extra DNS records";

    garden.services.headscale = self.lib.mkServiceOpt "headscale" {
      port = 4001;
      host = "0.0.0.0";
      domain = "hs.${config.garden.domain}";
      inherit (config.services.headscale) user group;
      depends.anywhere = ["blocky"];

      proxy = {
        visibility = "public";
        nginxExtra.proxyWebsockets = true;
      };

      oidc = {
        callbackURLs = ["https://${cfg.domain}/oidc/callback"];
        pkceEnabled = true;
      };
    };
  };

  imports = [
    (lib.mkAliasOptionModule ["garden" "services" "headscale" "prefixes"] ["services" "headscale" "settings" "prefixes"])
  ];

  config = lib.mkIf cfg.enable {
    garden.persist.dirs = [
      {
        inherit (cfg) user group;
        directory = "/var/lib/headscale";
      }
    ];

    # wait for pocket-id and blocky to start
    systemd.services.headscale = let
      services = builtins.concatLists [
        (lib.optionals config.garden.services.pocket-id.enable ["pocket-id.service"])
        (lib.optionals config.garden.services.blocky.enable ["blocky.service"])
      ];
    in {
      after = services;
      wants = services;
    };

    services = {
      headscale = {
        enable = true;
        address = cfg.host;
        inherit (cfg) port;

        settings = {
          server_url = "https://${cfg.domain}";

          dns = {
            nameservers.global =
              self.lib.hostsWhere self (_: hc: hc.config.garden.services.blocky.enable) {}
              |> lib.mapAttrsToList (_: hc: let
                inherit (hc.config.garden.networking.addresses) internal;
              in [
                (lib.optionals internal.ipv4.enable [internal.ipv4.address])
                (lib.optionals internal.ipv6.enable [internal.ipv6.address])
              ])
              |> lib.flatten;

            base_domain = config.garden.magic.internal.domain;
            search_domains = [config.garden.magic.internal.domain];
          };

          # https://pocket-id.org/docs/client-examples/headscale
          oidc = {
            issuer = "https://${config.garden.services.pocket-id.domain}";
            client_id = cfg.oidc.id;
            client_secret_path = secrets.oidc-headscale.path;
            pkce.enabled = true;
            only_start_if_oidc_is_available = true;
          };

          logtail.enabled = false;
        };
      };
    };
  };
}
