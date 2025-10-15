{
  lib,
  self,
  config,
  ...
}: let
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
      visibility = "public";
      dependsAnywhere = ["blocky" "pocket-id"];
      port = 4001;
      host = "0.0.0.0";
      domain = "hs.${config.garden.domain}";
      nginxExtraConf = {
        proxyWebsockets = true;
      };
    };
  };

  imports = [
    (lib.mkAliasOptionModule ["garden" "services" "headscale" "prefixes"] ["services" "headscale" "settings" "prefixes"])
  ];

  config = lib.mkIf cfg.enable {
    garden.persist.dirs = [
      {
        inherit (config.services.headscale) user group;
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
      pocket-id.oidc-clients.headscale = {
        launchURL = "https://${cfg.domain}";
        callbackURLs = ["https://${cfg.domain}/oidc/callback"];
        pkceEnabled = true;

        secret = {
          inherit (config.services.headscale) user group;
        };
      };

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
          oidc = let
            id = config.services.pocket-id;
          in {
            issuer = "https://${config.garden.services.pocket-id.domain}";
            client_id = id.oidc-clients.headscale.id;
            client_secret_path = id.oidc-clients.headscale.secret.path;
            pkce.enabled = true;
            only_start_if_oidc_is_available = true;
          };

          logtail.enabled = false;
        };
      };
    };
  };
}
