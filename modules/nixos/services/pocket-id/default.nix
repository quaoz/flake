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
    port = 4002;
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
    garden.secrets = {
      gen.pocket-id-encryption-key = {
        inherit user group;
        type = "base64";
      };

      other = [
        {
          inherit user group;
          path = "api/maxmind.age";
          shared = true;
        }
      ];
    };

    garden.persist.dirs = [
      {
        inherit user group;
        directory = config.services.pocket-id.dataDir;
      }
    ];

    services.pocket-id = {
      enable = true;
      purgeClients = true;

      # https://pocket-id.org/docs/configuration/environment-variables
      settings = {
        APP_URL = "https://${cfg.domain}";
        PORT = cfg.port;
        HOST = cfg.host;

        PUID = config.users.users.${user}.uid;
        PGID = config.users.groups.${group}.gid;

        TRUST_PROXY = true;
        ANALYTICS_DISABLED = true;

        UI_CONFIG_DISABLED = true;
        ALLOW_USER_SIGNUPS = "withToken";

        ENCRYPTION_KEY_FILE = secrets.pocket-id-encryption-key.path;
        MAXMIND_LICENSE_KEY_FILE = secrets."api-maxmind-${user}".path;
      };
    };
  };
}
