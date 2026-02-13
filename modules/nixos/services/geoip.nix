{
  self,
  lib,
  config,
  ...
}: let
  inherit (config.age) secrets;
  cfg = config.garden.services.geoip;
in {
  options.garden.services.geoip = self.lib.mkServiceOpt "geoip" {
    user = "geoip";
    group = "geoip";
  };

  config = lib.mkIf cfg.enable {
    garden = {
      profiles.persistence.dirs = [
        {
          inherit (cfg) user group;
          directory = config.services.geoipupdate.settings.DatabaseDirectory;
        }
      ];

      secrets.other = [
        {
          inherit (cfg) user group;
          path = "api/maxmind.age";
          shared = true;
        }
      ];
    };

    users = {
      users.${cfg.user} = {
        inherit (cfg) group;
        createHome = false;
        isSystemUser = true;
      };
      groups.${cfg.group} = {};
    };

    systemd.services.geoipupdate.serviceConfig = {
      User = cfg.user;
      Group = cfg.group;
    };

    services.geoipupdate = {
      enable = true;
      interval = "weekly";

      settings = {
        AccountID = 1224291;
        DatabaseDirectory = "/var/lib/geoip";
        EditionIDs = ["GeoLite2-City"];
        LicenseKey = secrets."api-maxmind-${cfg.user}".path;
      };
    };
  };
}
