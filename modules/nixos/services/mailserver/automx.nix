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
          ];
        };
      };
    };
  };
}
