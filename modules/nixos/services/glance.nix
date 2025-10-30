{
  lib,
  self,
  config,
  ...
}: let
  inherit (config.age) secrets;
  cfg = config.garden.services.glance;
in {
  options.garden.services.glance = self.lib.mkServiceOpt "glance" {
    port = 3007;
    host = "0.0.0.0";
    domain = "home.internal.${config.garden.domain}";
    proxy.visibility = "internal";
  };

  config = lib.mkIf cfg.enable {
    garden.secrets.normal.glance-env-file.generator = self.lib.mkEnvFile {
      AGENT_TOKEN = secrets.glance-agent-token;
    };

    services.glance = {
      enable = true;
      environmentFile = secrets.glance-env-file.path;

      settings = {
        server = {
          inherit (cfg) host port;
          proxied = true;
        };

        branding.hide-footer = true;

        pages = [
          {
            name = "home";
            width = "slim";
            center-vertically = true;
            hide-desktop-navigation = true;

            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "clock";
                    hour-format = "24h";
                  }
                  {
                    type = "weather";
                    location = "Leeds, United Kingdom";
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        links = [
                          {
                            title = "Minerva";
                            url = "https://minerva.leeds.ac.uk/";
                          }
                          {
                            title = "Timetable";
                            url = "https://mytimetable.leeds.ac.uk/";
                          }
                          {
                            title = "Teams";
                            url = "https://teams.microsoft.com/v2/";
                          }
                        ];
                      }
                      {
                        links = [
                          {
                            title = "LastFM";
                            url = "https://www.last.fm/user/quaoz";
                          }
                          {
                            title = "GitHub";
                            url = "https://github.com/quaoz";
                          }
                        ];
                      }
                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "monitor";
                    cache = "30s";
                    title = "services";
                    style = "compact";

                    sites =
                      self.lib.hosts self {}
                      |> lib.mapAttrsToList (
                        _: hc:
                          lib.filterAttrs (
                            _: sc:
                              sc.enable
                              && sc.dash.enable
                          )
                          hc.config.garden.services
                          |> lib.mapAttrsToList (
                            title: sc: {
                              inherit (sc.dash) icon;
                              inherit title;
                              url = sc.dash.launchURL;
                              check-url = sc.dash.healthURL;
                              alt-status-codes = sc.dash.okCodes;
                            }
                          )
                      )
                      |> lib.flatten;
                  }
                  {
                    type = "server-stats";
                    servers =
                      self.lib.hostsWhere self (_: hc: hc.config.garden.services.glance-agent.enable) {}
                      |> lib.mapAttrsToList (hn: hc: {
                        type = "remote";
                        token = "\${AGENT_TOKEN}";
                        url = "http://${hn}:${builtins.toString hc.config.garden.services.glance-agent.port}";
                      });
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
