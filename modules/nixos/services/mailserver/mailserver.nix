{
  inputs,
  self,
  lib,
  config,
  ...
}: let
  inherit (config.age) secrets;

  accounts =
    self.lib.hosts self {}
    |> lib.mapAttrsToList (
      _: hc:
        lib.filterAttrs (
          _: sc:
            sc.enable
            && sc.mail.enable
        )
        hc.config.garden.services
        |> lib.mapAttrs' (sn: sc: {
          name = "${sc.mail.account}@${baseDomain}";

          value = {
            inherit (sc.mail) sendOnly;
            aliases = [sc.mail.account];
            hashedPasswordFile = secrets."_mailserver-${sn}-hash".path;
          };
        })
    )
    |> self.lib.safeMerge;

  baseDomain = config.garden.domain;
  cfg = config.garden.services.mailserver;
in {
  options.garden.services.mailserver = self.lib.mkServiceOpt "mailserver" {
    domain = "mail.${baseDomain}";
    depends.local = ["redis" "nginx"];

    proxy = {
      enable = false;
      visibility = "public";
    };
  };

  imports = [
    inputs.simple-nixos-mailserver.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    garden = let
      user = config.mailserver.vmailUserName;
      group = config.mailserver.vmailGroupName;
    in {
      persist.dirs = builtins.concatLists [
        (
          builtins.map (directory: {
            inherit user group directory;
          }) [
            config.mailserver.mailDirectory
            config.mailserver.indexDir
            config.mailserver.sieveDirectory
          ]
        )

        [
          {
            inherit (config.services.rspamd) user group;
            directory = config.mailserver.dkimKeyDirectory;
          }
        ]
      ];

      secrets = {
        other =
          builtins.map (path: {
            inherit user group path;
          }) [
            "services/mailserver/me.age"
            "services/mailserver/admin.age"
            "services/mailserver/noreply.age"
          ];

        normal =
          self.lib.hosts self {}
          |> lib.mapAttrsToList (
            _: hc:
              lib.filterAttrs (_: sc: sc.enable && sc.mail.enable) hc.config.garden.services
              |> lib.mapAttrsToList (sn: sc: {
                "mailserver-${sn}" = {
                  inherit (sc) group;
                  owner = sc.user;
                  generator.script = "alnum";
                };

                "_mailserver-${sn}-hash" = {
                  inherit group;
                  owner = user;
                  generator = {
                    script = "bcrypt";
                    dependencies.input = secrets."mailserver-${sn}";
                  };
                };
              })
          )
          |> lib.flatten
          |> self.lib.safeMerge;
      };
    };

    services = {
      postfix.config.smtp_hello_name = config.mailserver.fqdn;
    };

    # isn't automatically detected as nginx isn't proxying mail.xenia.dog
    security.acme.certs.${baseDomain}.extraDomainNames = [config.mailserver.fqdn];

    mailserver = {
      enable = true;
      openFirewall = true;

      stateVersion = 3;

      useFsLayout = true;
      vmailUserName = "vmail";
      vmailGroupName = "vmail";

      mailDirectory = "/srv/mail/vmail";
      dkimKeyDirectory = "/srv/mail/dkim";
      sieveDirectory = "/srv/mail/sieve";
      indexDir = "/srv/mail/index";

      enableImap = true; # 143
      enableImapSsl = true; # 993
      enablePop3 = false; # 110
      enablePop3Ssl = false; # 995
      enableSubmission = false; # 587
      enableSubmissionSsl = true; # 465
      enableManageSieve = true; # 4190

      dkimKeyBits = 4096;
      dkimSelector = "mail";
      dkimSigning = true;

      hierarchySeparator = "/";
      localDnsResolver = false;
      fqdn = cfg.domain;
      domains = ["${baseDomain}"];

      certificateScheme = "acme";
      acmeCertificateName = baseDomain;

      fullTextSearch = {
        enable = true;
        autoIndex = true;
        enforced = "body";
        filters = [
          "stopwords"
          "snowball"
        ];
      };

      loginAccounts =
        accounts
        // {
          "${config.me.username}@${baseDomain}" = {
            hashedPasswordFile = secrets.mailserver-me.path;
            aliases = [
              config.me.username
              "me"
              "me@${baseDomain}"
            ];
          };

          "admin@${baseDomain}" = {
            hashedPasswordFile = secrets.mailserver-admin.path;
            aliases = [
              "admin"
              "acme"
              "acme@${baseDomain}"
              "abuse"
              "abuse@${baseDomain}"
              "dmarc"
              "dmarc@${baseDomain}"
              "postmaster"
              "postmaster@${baseDomain}"
            ];
          };

          "noreply@${baseDomain}" = {
            hashedPasswordFile = secrets.mailserver-noreply.path;
            sendOnly = true;
            aliases = [
              "noreply"
            ];
          };
        };

      mailboxes = {
        Archive = {
          auto = "subscribe";
          specialUse = "Archive";
        };
        Drafts = {
          auto = "subscribe";
          specialUse = "Drafts";
        };
        Sent = {
          auto = "subscribe";
          specialUse = "Sent";
        };
        Junk = {
          auto = "subscribe";
          specialUse = "Junk";
        };
        Trash = {
          auto = "subscribe";
          specialUse = "Trash";
        };
      };
    };
  };
}
