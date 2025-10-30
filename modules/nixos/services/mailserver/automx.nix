{
  self,
  lib,
  config,
  ...
}: let
  baseDomain = config.garden.domain;
  mailDomain = config.garden.services.mailserver.domain;
  cfg = config.garden.services.automx;
in {
  options.garden.services.automx = self.lib.mkServiceOpt "automx" {
    domain = "autoconfig.${baseDomain}";
    depends.local = ["nginx" "mailserver"];

    proxy = {
      enable = false;
      visibility = "public";
    };
  };

  config = lib.mkIf cfg.enable {
    garden.magic.public.domains."${baseDomain}".extraRecords = [
      {
        type = "cname";
        label = "autodiscover";
        target = "${cfg.domain}.";
      }
    ];

    security.acme.certs.${baseDomain}.extraDomainNames = ["autodiscover.${baseDomain}"];

    services = {
      nginx.virtualHosts."${cfg.domain}".enableACME = lib.mkForce false;

      automx2 = {
        enable = true;
        domain = baseDomain;

        settings = {
          provider = "${baseDomain}";
          domains = ["${baseDomain}"];
          servers = [
            {
              type = "imap";
              name = "${mailDomain}";
            }
            {
              type = "smtp";
              name = "${mailDomain}";
            }
            # these need to be created for each user in radicale (https://cal.xenia.dog/),
            # set the `HREF` field to calendar and contacts respectively to pick them up
            {
              type = "caldav";
              port = 443;
              url = "https://cal.xenia.dog/%EMAILADDRESS%/calendar/";
            }
            {
              type = "carddav";
              port = 443;
              url = "https://cal.xenia.dog/%EMAILADDRESS%/contacts/";
            }
          ];
        };
      };
    };
  };
}
