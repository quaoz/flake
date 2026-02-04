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
    port = 4001;
    host = "0.0.0.0";
    domain = "hs.${config.garden.domain}";
    inherit (config.services.headscale) user group;
    depends.anywhere = ["blocky"];

    proxy = {
      visibility = "public";
      nginxExtra.proxyWebsockets = true;
    };

    dash = {
      enable = true;
      icon = "sh:headscale-light";
      healthURL = "https://${cfg.domain}/health";
    };

    oidc = {
      enable = true;
      pkceEnabled = true;
      callbackURLs = ["https://${cfg.domain}/oidc/callback"];
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

          # https://pocket-id.org/docs/client-examples/headscale
          oidc = {
            issuer = "https://${config.garden.services.pocket-id.domain}";
            client_id = cfg.oidc.id;
            client_secret_path = secrets.oidc-headscale.path;
            scope = ["openid" "profile" "email" "groups"];
            pkce.enabled = true;
            only_start_if_oidc_is_available = true;
          };

          declarative = {
            autoApprovers = {
              exitNode = ["tag:exit"];
            };

            tagOwners = {
              exit = ["group:admin@xenia.dog"];
              server = ["group:admin@xenia.dog"];
            };

            # TODO: headscale ACLs
            acls = [
              {
                src = ["*"];
                dst = ["*:*"];
              }
            ];
          };

          logtail.enabled = false;
        };
      };
    };
  };
}
