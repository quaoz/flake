{
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  cfg = config.garden.monitoring.fail2ban;
in {
  options.garden.monitoring.fail2ban = self.lib.mkMonitorOpt "fail2ban" {
    inherit (config.services.fail2ban) enable;
    port = 9003;
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.garden.services.geoip.enable;
        message = "fail2ban monitoring depends on geoip, enable `garden.service.geoip`";
      }
    ];

    systemd.services.prometheus-fail2ban-exporter = {
      description = "fail2ban prometheus exporter";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "geoipupdate.service"];

      script = ''
        geoip="${config.services.geoipupdate.settings.DatabaseDirectory}/GeoLite2-City.mmdb"
        i=0

        while [[ ! -f "$geoip" ]]; do
            sleep 1
            if ((++i > 120)); then
                echo "timed out waiting for '"$geoip"'"
                exit 1
            fi
        done

        ${lib.getExe pkgs.fail2ban-prometheus-exporter} \
          --web.listen-address 0.0.0.0:${builtins.toString cfg.port}    \
          --maxmind.db-path "$geoip"
      '';

      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = /tmp;
        User = "root";
        Group = "root";

        # hardening
        CapabilityBoundingSet = [""];
        DeviceAllow = [""];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  };
}
