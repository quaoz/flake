{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.garden.services.prometheus;
in {
  options.garden.services.prometheus = self.lib.mkServiceOpt "prometheus" {
    port = 9000;
  };

  config = lib.mkIf cfg.enable {
    garden.persist.dirs = [
      {
        directory = "/var/lib/${config.services.prometheus.stateDir}";
        user = "prometheus";
        group = "prometheus";
      }
    ];

    services.prometheus = {
      enable = true;
      inherit (cfg) port;

      scrapeConfigs =
        self.lib.hostsWhere self (_: hc: hc.config.garden.monitoring.enable) {}
        |> lib.mapAttrsToList (
          hn: hc: (
            lib.filterAttrs (_: sc: builtins.isAttrs sc && sc.enable) hc.config.garden.monitoring
            |> lib.mapAttrsToList (sn: sc: {
              job_name = "${hn}-${sn}";
              static_configs = [
                {
                  targets = ["${hn}:${builtins.toString sc.port}"];
                }
              ];
            })
          )
        )
        |> lib.flatten;
    };
  };
}
