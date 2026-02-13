{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  hasMonitor = name:
    self.lib.hostsWhere self (
      _: hc:
        builtins.hasAttr name hc.config.garden.profiles.monitoring
        && hc.config.garden.profiles.monitoring.${name}.enable
    ) {}
    != {};

  hasLocalMonitor = name: config.garden.services.${name}.enable && config.garden.profiles.monitoring.${name}.enable;

  inherit (config.age) secrets;
  cfg = config.garden.services.grafana;
in {
  options.garden.services.grafana = self.lib.mkServiceOpt "grafana" {
    port = 9100;
    host = "0.0.0.0";
    domain = "grafana.${config.garden.domain}";
    user = "grafana";
    group = "grafana";
    depends.local = ["prometheus" "postgresql"];

    proxy = {
      visibility = "public";
      nginxExtra.proxyWebsockets = true;
    };

    dash = {
      enable = true;
      icon = "sh:grafana-light";
      healthURL = "https://${cfg.domain}/api/health";
    };

    oidc = {
      enable = true;
      pkceEnabled = true;
      callbackURLs = ["https://${cfg.domain}/login/generic_oauth"];
    };
  };

  config = lib.mkIf cfg.enable {
    garden.profiles.persistence.dirs = [
      {
        directory = config.services.grafana.dataDir;
        inherit (cfg) user group;
      }
    ];

    services = {
      postgresql = {
        ensureDatabases = ["grafana"];
        ensureUsers = [
          {
            name = "grafana";
            ensureDBOwnership = true;
          }
        ];
      };

      grafana = {
        enable = true;

        declarativePlugins = with pkgs.grafanaPlugins; lib.optionals (hasMonitor "blocky") [grafana-piechart-panel];

        provision = {
          enable = true;

          dashboards.settings = {
            apiVersion = 1;

            providers = [
              (lib.mkIf (hasMonitor "blocky") {
                name = "Blocky";
                options.path = "${pkgs.dashboards}/share/blocky.json";
              })

              (lib.mkIf (hasLocalMonitor "blocky") {
                name = "Blocky Query";
                options.path = "${pkgs.dashboards}/share/blocky-query.json";
              })

              (lib.mkIf (hasMonitor "node") {
                name = "Node";
                options.path = "${pkgs.dashboards}/share/node.json";
              })

              (lib.mkIf (hasMonitor "fail2ban") {
                name = "Fail2ban";
                options.path = "${pkgs.dashboards}/share/fail2ban.json";
              })
            ];
          };

          datasources.settings = {
            apiVersion = 1;

            deleteDatasources = [
              {
                name = "prometheus";
                orgId = 1;
              }
              (lib.mkIf (hasLocalMonitor "blocky") {
                name = "blocky";
                orgId = 1;
              })
            ];

            datasources = [
              {
                name = "prometheus";
                type = "prometheus";
                access = "proxy";
                url = "http://127.0.0.1:${builtins.toString config.garden.services.prometheus.port}";
                orgId = 1;
              }
              (lib.mkIf (hasLocalMonitor "blocky") {
                name = "blocky";
                type = "postgres";
                access = "proxy";
                url = "/run/postgresql";
                user = "grafana";
                orgId = 1;
                jsonData = {
                  database = "blocky";
                  sslmode = "disable";
                };
              })
            ];
          };
        };

        settings = {
          server = {
            inherit (cfg) domain;
            http_port = cfg.port;
            http_addr = cfg.host;
            root_url = "https://${cfg.domain}/";
            enforce_domain = true;
            enable_gzip = true;
          };

          analytics = {
            reporting_enabled = false;
            feedback_links_enabled = false;
          };

          security = {
            cookie_secure = true;
            csrf_trusted_origins = [
              "https://${cfg.domain}"
              "https://${config.garden.services.pocket-id.domain}"
            ];
            disable_initial_admin_creation = true;
          };

          database = {
            type = "postgres";
            host = "/run/postgresql";
            user = "grafana";
            name = "grafana";
          };

          # needed for blocky dashboard
          panels.disable_sanitize_html = true;

          # https://pocket-id.org/docs/client-examples/grafana
          # https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/generic-oauth/#configuration-options
          "auth.generic_oauth" = let
            idomain = "https://${config.garden.services.pocket-id.domain}";
          in {
            enabled = true;
            name = "Pocket ID";

            auth_style = "AutoDetect";
            auth_url = "${idomain}/authorize";
            token_url = "${idomain}/api/oidc/token";
            api_url = "${idomain}/api/oidc/userinfo";

            auto_login = true;
            allow_sign_up = true;
            use_pkce = true;
            use_refresh_token = true;

            client_id = cfg.oidc.id;
            client_secret = "$__file{${secrets.oidc-grafana.path}}";

            scopes = "openid email profile groups";
            email_attribute_name = "email:primary";
            role_attribute_path = "contains(groups[*], 'admin') && 'GrafanaAdmin' || 'Viewer'";
            allow_assign_grafana_admin = true;
          };
        };
      };
    };
  };
}
