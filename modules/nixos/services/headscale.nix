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
      visibility = "public";
      dependsAnywhere = ["pocket-id"];
      port = 3757;
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
    garden = {
      persist.dirs = [
        {
          inherit (config.services.headscale) user group;
          directory = "/var/lib/headscale";
        }
      ];

      secrets.other = [
        {
          inherit (config.services.headscale) user group;
          path = "services/headscale/oidc-secret.age";
        }
      ];
    };

    # wait for pocket-id to start
    systemd.services.headscale = lib.mkIf config.garden.services.pocket-id.enable {
      after = ["pocket-id.service"];
      wants = ["pocket-id.service"];
    };

    services = {
      headscale = {
        enable = true;
        address = cfg.host;
        inherit (cfg) port;

        settings = {
          server_url = "https://${cfg.domain}";

          dns = {
            nameservers.global = ["9.9.9.9"];
            base_domain = config.garden.magic.internal.domain;
            search_domains = [config.garden.magic.internal.domain];
          };

          oidc = {
            issuer = "https://${config.garden.services.pocket-id.domain}";
            client_id = "0d038043-28cd-426b-909d-7d4e43606f13";
            client_secret_path = secrets.headscale-oidc-secret.path;
            pkce.enabled = true;
            only_start_if_oidc_is_available = true;
          };

          logtail.enabled = false;
        };
      };
    };
  };
}
