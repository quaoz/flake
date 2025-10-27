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
    port = 3003;
    host = "127.0.0.1";
    domain = "cal.${baseDomain}";
    depends.local = ["mailserver"];
    proxy.visibility = "public";

    dash = {
      enable = true;
      icon = "sh:radicale-light";
    };
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
          hosts = ["0.0.0.0:${builtins.toString cfg.port}"];
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
