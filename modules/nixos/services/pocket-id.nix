{
  lib,
  self,
  config,
  ...
}: let
  inherit (config.services.pocket-id) user group;
  inherit (config.garden) domain;
  inherit (config.age) secrets;

  cfg = config.garden.services.pocket-id;
in {
  options.garden.services.pocket-id = self.lib.mkServiceOpt "pocket-id" {
    visibility = "public";
    port = 1411;
    host = "0.0.0.0";
    domain = "id.${domain}";
    nginxExtraConf = {
      extraConfig = ''
        proxy_busy_buffers_size 512k;
        proxy_buffers 4 512k;
        proxy_buffer_size 256k;
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    garden.secrets.other = [
      {
        inherit user group;
        path = "services/pocket-id/encryption-key.age";
      }
      {
        inherit user group;
        path = "services/pocket-id/maxmind-api.age";
      }
    ];

    garden.persist.dirs = [
      {
        inherit (config.services.pocket-id) user group;
        directory = config.services.pocket-id.dataDir;
      }
    ];

    services.pocket-id = {
      enable = true;

      # https://pocket-id.org/docs/configuration/environment-variables
      settings = {
        APP_URL = "https://${cfg.domain}";
        PORT = cfg.port;
        HOST = cfg.host;

        PUID = config.users.users.${user}.uid;
        PGID = config.users.groups.${group}.gid;

        TRUST_PROXY = true;
        ANALYTICS_DISABLED = true;
        ALLOW_USER_SIGNUPS = "withToken";

        ENCRYPTION_KEY_FILE = secrets.pocket-id-encryption-key.path;
        MAXMIND_LICENSE_KEY_FILE = secrets.pocket-id-maxmind-api.path;
      };
    };
  };
}
