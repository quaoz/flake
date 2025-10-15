{
  config,
  self,
  pkgs,
  lib,
  ...
}: let
  inherit (config.age) secrets;
  cfg = config.garden.services.nginx;
in {
  # TODO: better support multiple domains?
  options = {
    services.nginx.virtualHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule ({config, ...}: let
          domain = config._module.args.name;
        in {
          config = lib.mkIf (domain != "localhost") {
            quic = lib.mkDefault true;
            kTLS = lib.mkDefault true;
            forceSSL = lib.mkDefault true;
            enableACME = lib.mkDefault false;
            useACMEHost = lib.mkDefault cfg.domain;
          };
        })
      );
    };

    garden.services.nginx = self.lib.mkServiceOpt "nginx" {
      inherit (config.garden) domain;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.nginx.extraGroups = ["acme"];
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    garden = let
      user = "acme";
      group = "acme";
    in {
      secrets.other = [
        {
          inherit user group;
          path = "services/acme/cf-dns-api.age";
        }
      ];

      persist.dirs = [
        {
          inherit user group;
          directory = "/var/lib/acme";
        }
      ];
    };

    security.acme = {
      acceptTerms = true;

      defaults = {
        email = "acme@${cfg.domain}";
        dnsResolver = "1.1.1.1:53";

        dnsProvider = "cloudflare";
        credentialFiles.CF_DNS_API_TOKEN_FILE = secrets.acme-cf-dns-api.path;
      };

      certs.${cfg.domain} = {
        extraDomainNames =
          config.services.nginx.virtualHosts
          |> lib.filterAttrs (_: x: x.useACMEHost == cfg.domain)
          |> builtins.attrNames;
      };
    };

    services.nginx = {
      enable = true;
      statusPage = true;

      logError = "/var/log/nginx/error.log";

      package = pkgs.nginxQuic;

      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      experimentalZstdSettings = true;

      sslCiphers = "EECDH+aRSA+AESGCM:EDH+aRSA:EECDH+aRSA:+AES256:+AES128:+SHA1:!CAMELLIA:!SEED:!3DES:!DES:!RC4:!eNULL";
      sslProtocols = "TLSv1.3 TLSv1.2";
    };
  };
}
