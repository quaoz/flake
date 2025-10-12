{
  config,
  lib,
  self,
  ...
}: let
  full = config.garden.services.grafana.enable;
  cfg = config.garden.monitoring.blocky;
in {
  options.garden.monitoring.blocky = self.lib.mkMonitorOpt "blocky" {
    inherit (config.garden.services.blocky) enable;
    port = 9002;
  };

  config = lib.mkIf cfg.enable {
    warnings = lib.optionals (!full) ["Blocky must be ran on the same host as grafana for query monitoring."];

    garden.services.blocky.depends.local = ["unbound"] ++ lib.optionals full ["postgresql"];

    systemd.services = lib.mkIf full {
      blocky = {
        after = ["postgresql.service"];
        wants = ["postgresql.service"];

        serviceConfig.RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
      };

      postgresql.postStart = lib.mkAfter ''
        psql -tAc 'GRANT CONNECT ON DATABASE blocky TO grafana'
        psql -d blocky -tAc 'GRANT USAGE ON SCHEMA public TO grafana;'
        psql -d blocky -tAc 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana'
      '';
    };

    services = {
      postgresql = lib.mkIf full {
        ensureDatabases = ["blocky"];
        ensureUsers = [
          {
            name = "blocky";
            ensureDBOwnership = true;
          }
        ];
      };

      blocky = {
        settings = {
          ports.http = cfg.port;

          log.privacy = !full;

          queryLog = lib.mkIf full {
            type = "postgresql";
            target = "postgres://blocky?host=/run/postgresql";
          };

          prometheus = {
            enable = true;
            path = "/metrics";
          };
        };
      };
    };
  };
}
