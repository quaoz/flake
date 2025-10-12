{
  lib,
  config,
  ...
}: let
  baseDomain = config.garden.domain;
  cfg = config.garden.services.mailserver;
in {
  options.garden.services.mailserver.dns.enable = lib.mkEnableOption "mailserver DNS management";

  config = lib.mkIf cfg.dns.enable {
    assertions = [
      {
        assertion = lib.hasSuffix baseDomain cfg.domain;
        message = "${cfg.domain} is not a subdomain of ${baseDomain}, mailserver DNS management will not work.";
      }
      {
        assertion = cfg.dns.enable -> config.garden.magic.public.enable;
        message = "`garden.magic.public` must be enabled for mailserver DNS management to work";
      }
    ];

    # tests:
    # - https://internet.nl/test-mail/
    # - https://mecsa.jrc.ec.europa.eu/
    # - https://www.mail-tester.com/
    # - https://mxtoolbox.com/
    #
    # (all of these should pass fully)
    garden.magic.public.domains.${baseDomain}.extraRecords = [
      {
        # MX record, define mailserver for base domain
        #
        # $ dig +short xenia.dog MX
        # > 10 mail.xenia.dog.
        type = "mx";
        label = "@";
        priority = 10;
        target = "${cfg.domain}.";
      }

      # autodiscovery (https://www.rfc-editor.org/rfc/rfc6186)
      {
        type = "srv";
        label = "_submissions._tcp";
        priority = 10;
        weight = 0;
        port = 465;
        target = "${cfg.domain}.";
      }
      {
        type = "srv";
        label = "_imap._tcp";
        priority = 10;
        weight = 0;
        port = 143;
        target = "${cfg.domain}.";
      }
      {
        type = "srv";
        label = "_imaps._tcp";
        priority = 10;
        weight = 0;
        port = 993;
        target = "${cfg.domain}.";
      }

      # forgery protection (SPF, DMARC, DKIM)
      {
        # DMARC record, instruct mailservers to reject mail which fails SPF or DKIM
        # - https://github.com/internetstandards/toolbox-wiki/blob/main/DMARC-how-to.md
        #
        # $ dig +short _dmarc.xenia.dog TXT
        # > "v=DMARC1; p=reject; adkim=s; aspf=s; rua=mailto:dmarc@xenia.dog; ruf=mailto:dmarc@xenia.dog; fo=1"
        type = "dmarc_builder";
        parameters = {
          label = "@";
          version = "DMARC1";
          policy = "reject";
          rua = ["mailto:dmarc@${baseDomain}"];
          ruf = ["mailto:dmarc@${baseDomain}"];
          alignmentSPF = "strict";
          alignmentDKIM = "strict";
          failureOptions = "1";
        };
      }
      {
        # SPF record, authorise incoming mailservers (MX) to send mail for base domain
        # - https://github.com/internetstandards/toolbox-wiki/blob/main/SPF-how-to.md
        #
        # $ dig +short xenia.dog TXT
        # > "v=spf1 mx -all"
        type = "spf_builder";
        parameters = {
          label = "@";
          parts = [
            "v=spf1"
            "mx"
            "-all"
          ];
        };
      }
      {
        # SPF HELO record, see: http://www.open-spf.org/FAQ/Common_mistakes/#helo
        #
        # $ dig +short mail.xenia.dog TXT
        # > "v=spf1 a -all"
        type = "spf_builder";
        parameters = {
          label = "mail";
          parts = [
            "v=spf1"
            "a"
            "-all"
          ];
        };
      }
      {
        # DKIM record, key used to sign emails
        # - https://github.com/internetstandards/toolbox-wiki/blob/main/DKIM-how-to.md
        #
        # $ dig +short mail._domainkey.xenia.dog TXT
        # > "v=DKIM1; k=rsa; p=..."
        type = "dkim_builder";
        parameters = {
          selector = "mail";
          keytype = "rsa";
          # /srv/mail/dkim/${baseDomain}.mail.txt
          pubkey = "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAzSpWUFxqTFBErLSBhD1OHjgthzwHdCPP/R0SgAuxTDsYC/lHwUH/4AY7cQ8xTi32c5mK8hVwdOVQFIKhF6GaQy4qXGd0KFzhEgDfY6Pc+K7Qdnu3BkyaQTSlk/FMR2e/qkkCKeEukzyjgpIMp3K9VweUqoiOwYrrOi60m32hYxYyCY6oy+lLBuaXmXr2cELTeDxNE925AosSVweuOER7wUiQtibLn8KmNo05C5O+so1hO+CUasNF1pdATIWaoEFVB/Lz2R/kP8JCHllxZQqnleQN0oftIOrRCux+hGXlVA5GX0RFG1ztqu73l+AsI3VgGdDswVs9rv9LB3XnmHcPwHEd78vkRsWK5DKHbQZczxz/2Xc6wPlf/BpEqsGsYuEYisuy5zP1KC90t2/6N59aC+cWwXZQJ0x0YXjYv+WqH3+4RWbGIa8X2v/1e11hKi00s1UMngwIMMDoKWCWcehWl8H3X4IHMvfqrmeJcnAoTs1Nbpqd2w0z8SaPkNy44gS0tleVwEsScBi12d2d8JRPx8ULVZ04G2AgxjjGyovo5/cNO3hWNj1xh78Y+f5831R7MxF58mixDvKLhspYihps8W9cvv7rTNsToafSKSkI93XNZzc0v1X+Jqjji7RAK3wTPK/LBXNHpq63UljguwgIwNeN31fxa5QfR993kTQv93ECAwEAAQ==";
        };
      }

      # secure mailserver connection (CAA, DANE)
      {
        # CAA record, specify which certificate authorities can issue certificates for the base domain
        #
        # $ dig +short xenia.dog CAA
        # > 0 iodef "mailto:admin@xenia.dog"
        # > 0 issue "letsencrypt.org"
        # > 0 issuewild ";"
        type = "caa_builder";
        parameters = {
          label = "@";
          iodef = "mailto:admin@${baseDomain}";
          issue = ["letsencrypt.org"];
          issuewild = "none";
        };
      }
      {
        # DANE-EE TLSA record, verify our identity before message transfer
        # - https://github.com/internetstandards/toolbox-wiki/blob/main/DANE-for-SMTP-how-to.md
        #
        # $ dig +short _25._tcp.mail.xenia.dog TLSA
        # > 3 1 1 05ED2787997F764AD6307465D77BF40D4FC990B72E76450AD2E5A52F 258683E0
        type = "tlsa";
        label = "_25._tcp.mail";
        usage = 3;
        selector = 1;
        matching_type = 1;
        # openssl x509 -in /var/lib/acme/${baseDomain}/cert.pem -pubkey -noout | openssl pkey -pubin -outform DER | openssl sha256
        certificate = "05ed2787997f764ad6307465d77bf40d4fc990b72e76450ad2e5a52f258683e0";
      }
      {
        # DANE-TA TLSA record (rollover)
        #
        # $ dig +short _25._tcp.mail.xenia.dog TLSA
        # > 2 1 1 CBBC559B44D524D6A132BDAC672744DA3407F12AAE5D5F722C5F6C79 13871C75
        type = "tlsa";
        label = "_25._tcp.mail";
        usage = 2;
        selector = 1;
        matching_type = 1;
        # openssl x509 -in /var/lib/acme/${baseDomain}/chain.pem -pubkey -noout | openssl pkey -pubin -outform DER | openssl sha256
        certificate = "cbbc559b44d524d6a132bdac672744da3407f12aae5d5f722c5f6c7913871c75";
      }
    ];
  };
}
