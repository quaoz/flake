{
  self,
  lib,
  config,
  ...
}: let
  inherit (config.age) secrets;

  user = "geoip";
  group = "geoip";

  cfg = config.garden.services.geoip;
in {
  options.garden.services.geoip = self.lib.mkServiceOpt "geoip" {};

  config = lib.mkIf cfg.enable {
    garden = {
      persist.dirs = [
        {
          inherit user group;
          directory = config.services.geoipupdate.settings.DatabaseDirectory;
        }
      ];

      secrets.other = [
        {
          inherit user group;
          path = "api/maxmind.age";
          shared = true;
        }
      ];
    };

    users = {
      users.${user} = {
        inherit group;
        createHome = false;
        isSystemUser = true;
      };
      groups.geoip = {};
    };

    systemd.services.geoipupdate.serviceConfig = {
      User = user;
      Group = group;
    };

    services.geoipupdate = {
      enable = true;
      interval = "weekly";

      settings = {
        AccountID = 1224291;
        DatabaseDirectory = "/var/lib/geoip";
        EditionIDs = ["GeoLite2-City"];
        LicenseKey = secrets."api-maxmind-${user}".path;
      };
    };
  };
}
