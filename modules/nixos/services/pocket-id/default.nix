{
  lib,
  self,
  config,
  ...
}: let
  inherit (config.garden) domain;
  inherit (config.age) secrets;

  cfg = config.garden.services.pocket-id;
in {
  options.garden.services.pocket-id = self.lib.mkServiceOpt "pocket-id" {
    port = 4002;
    host = "0.0.0.0";
    domain = "id.${domain}";
    inherit (config.services.pocket-id) user group;

    proxy = {
      visibility = "public";
      nginxExtra.extraConfig = ''
        proxy_busy_buffers_size 512k;
        proxy_buffers 4 512k;
        proxy_buffer_size 256k;
      '';
    };

    mail = {
      enable = true;
      account = "auth";
    };
  };

  config = lib.mkIf cfg.enable {
    garden = {
      secrets = {
        normal = {
          pocket-id-encryption-key = {
            inherit (cfg) group;
            owner = cfg.user;
            generator.script = "base64";
          };

          # SMTP_PASSWORD_FILE doesn't work so do this instead ig??
          pocket-id-env-file = {
            inherit (cfg) group;
            owner = cfg.user;

            generator = {
              dependencies.mail = secrets.mailserver-pocket-id;

              script = {
                deps,
                decrypt,
                ...
              }: ''
                echo "SMTP_PASSWORD='$(${decrypt} ${lib.escapeShellArg deps.mail.file})'"
              '';
            };
          };
        };

        other = [
          {
            inherit (cfg) user group;
            path = "api/maxmind.age";
            shared = true;
          }
        ];
      };

      persist.dirs = [
        {
          inherit (cfg) user group;
          directory = config.services.pocket-id.dataDir;
        }
      ];
    };

    services.pocket-id = {
      enable = true;
      purgeClients = true;

      environmentFile = secrets.pocket-id-env-file.path;

      # https://pocket-id.org/docs/configuration/environment-variables
      settings = {
        APP_URL = "https://${cfg.domain}";
        TRUST_PROXY = true;
        PORT = cfg.port;
        HOST = cfg.host;

        PUID = config.users.users.${cfg.user}.uid;
        PGID = config.users.groups.${cfg.group}.gid;

        ANALYTICS_DISABLED = true;

        ENCRYPTION_KEY_FILE = secrets.pocket-id-encryption-key.path;
        MAXMIND_LICENSE_KEY_FILE = secrets."api-maxmind-${cfg.user}".path;

        UI_CONFIG_DISABLED = true;
        ALLOW_USER_SIGNUPS = "withToken";

        # WATCH: https://github.com/pocket-id/pocket-id/issues/810
        EMAILS_VERIFIED = true;
        SMTP_HOST = config.garden.services.mailserver.domain;
        SMTP_PORT = 465;
        SMTP_FROM = "auth@${domain}";
        SMTP_USER = "auth@${domain}";
        # SMTP_PASSWORD_FILE = secrets.mailserver-pocket-id.path;
        SMTP_TLS = "tls";
      };
    };
  };
}
