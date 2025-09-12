{
  lib,
  self,
  config,
  ...
}: let
  inherit (config.age) secrets;

  cfg = config.garden.services.headscale;
in {
  options.garden.services.headscale = self.lib.mkServiceOpt "headscale" {
    visibility = "public";
    port = 3757;
    host = "0.0.0.0";
    domain = "hs.${config.garden.domain}";
    nginxExtraConf = {
      proxyWebsockets = true;
    };
  };

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

    services = {
      headscale = {
        enable = true;
        address = cfg.host;
        inherit (cfg) port;

        settings = {
          server_url = "https://${cfg.domain}";

          dns = {
            base_domain = "internal.${config.garden.domain}";
            nameservers.global = ["9.9.9.9"];
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
