{
  self,
  lib,
  config,
  ...
}: let
  baseDomain = config.garden.domain;
  cfg = config.garden.services.radicale;
in {
  options.garden.services.radicale = self.lib.mkServiceOpt "radicale" {
    visibility = "public";
    dependsLocal = ["nginx" "mailserver"];
    host = "127.0.0.1";
    port = 3003;
    domain = "cal.${baseDomain}";
  };

  config = lib.mkIf cfg.enable {
    garden = {
      persist.dirs = [
        {
          user = "radicale";
          group = "radicale";
          directory = config.services.radicale.settings.storage.filesystem_folder;
        }
      ];
    };

    services.radicale = {
      enable = true;

      settings = {
        server = {
          hosts = ["0.0.0.0:${cfg.port}"];
        };

        auth = {
          type = "imap";
          imap_host = "${config.mailserver.fqdn}";
          imap_security = "tls";
        };

        storage = {
          filesystem_folder = "/srv/mail/radicale";
        };
      };
    };
  };
}
