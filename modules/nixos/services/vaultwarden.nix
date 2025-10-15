{
  lib,
  self,
  config,
  pkgs,
  ...
}: let
  inherit (config.age) secrets;
  cfg = config.garden.services.vaultwarden;
in {
  options.garden.services.vaultwarden = self.lib.mkServiceOpt "vaultwarden" {
    visibility = "public";
    dependsAnywhere = ["pocket-id" "mailserver"];
    dependsLocal = ["postgresql"];
    port = 3004;
    host = "0.0.0.0";
    domain = "vault.${config.garden.domain}";
    nginxExtraConf = {
      proxyWebsockets = true;
    };
  };

  config = lib.mkIf cfg.enable {
    garden = {
      persist.dirs = [
        {
          directory = config.services.vaultwarden.config.DATA_DIR;
          user = "vaultwarden";
          group = "vaultwarden";
        }
        {
          directory = config.services.vaultwarden.backupDir;
          user = "vaultwarden";
          group = "vaultwarden";
        }
      ];

      secrets = {
        intermediary = [
          "services/vaultwarden/push-id.age"
          "services/vaultwarden/push-key.age"
        ];

        normal = {
          mailserver-vaultwarden = {
            owner = "vaultwarden";
            group = "vaultwarden";
            generator.script = "alnum";
            intermediary = true;
          };

          vaultwarden-admin-token = {
            generator.script = "alnum";
            intermediary = true;
          };

          vaultwarden-env-file = {
            owner = "vaultwarden";
            group = "vaultwarden";

            generator = {
              dependencies = {
                inherit
                  (config.age.secrets)
                  _oidc-vaultwarden
                  mailserver-vaultwarden
                  vaultwarden-admin-token
                  vaultwarden-push-id
                  vaultwarden-push-key
                  ;
              };

              script = {
                pkgs,
                deps,
                decrypt,
                ...
              }: let
                env = var: dep: "echo \"${var}='$(${decrypt} ${lib.escapeShellArg dep.file})'\"";
              in ''
                ${env "PUSH_INSTALLATION_ID" deps.vaultwarden-push-id}
                ${env "PUSH_INSTALLATION_KEY" deps.vaultwarden-push-key}
                ${env "SSO_CLIENT_SECRET" deps._oidc-vaultwarden}
                ${env "SMTP_PASSWORD" deps.mailserver-vaultwarden}

                salt="$(${lib.getExe pkgs.openssl} rand -base64 32)"
                token="$(${decrypt} ${lib.escapeShellArg deps.vaultwarden-admin-token.file})"
                echo "ADMIN_TOKEN='$(echo -n "$token" | ${lib.getExe pkgs.libargon2} "$salt" -e -id -k 65540 -t 3 -p 4)'"
                unset salt token
              '';
            };
          };
        };
      };
    };

    services = {
      pocket-id.oidc-clients.vaultwarden = {
        launchURL = "https://${cfg.domain}";
        callbackURLs = ["https://${cfg.domain}/identity/connect/oidc-signin"];
        pkceEnabled = true;

        secret = {
          user = "vaultwarden";
          group = "vaultwarden";
        };
      };

      vaultwarden = {
        enable = true;
        # TODO: remove once version supporting SSO (>1.34.3) in nixpkgs
        package = pkgs.vaultwarden.overrideAttrs (final: prev: {
          src = prev.src.override {
            rev = "3f010a50af51aa826c2889e252c39ef6fe382d77";
            hash = "sha256-iTTS3tqOqsAm5qY3BJ7FqDpBztbMzE4V1095wrLVsVQ=";
          };

          cargoHash = "sha256-F7we9rurJ7srz54lsuSrdoIZpkGE+4ncW3+wjEwaD7M=";

          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            inherit (final) src;
            name = "${final.pname}-${final.version}";
            hash = final.cargoHash;
          };
        });

        backupDir = "/srv/vaultwarden/backup";
        environmentFile = secrets.vaultwarden-env-file.path;

        # https://github.com/dani-garcia/vaultwarden/blob/main/.env.template
        config = {
          DOMAIN = "https://${cfg.domain}";
          ROCKET_ADDRESS = cfg.host;
          ROCKET_PORT = cfg.port;
          DATA_DIR = "/srv/vaultwarden";

          PUSH_ENABLED = true;
          PUSH_RELAY_URI = "https://api.bitwarden.eu";
          PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";

          # https://github.com/dani-garcia/vaultwarden/wiki/Enabling-SSO-support-using-OpenId-Connect
          SSO_ENABLED = true;
          SSO_ONLY = true;
          SSO_AUTHORITY = "https://${config.garden.services.pocket-id.domain}";
          SSO_PKCE = true;
          SSO_CLIENT_ID = config.services.pocket-id.oidc-clients.vaultwarden.id;
          SSO_SIGNUPS_MATCH_EMAIL = false;

          # https://github.com/dani-garcia/vaultwarden/wiki/SMTP-Configuration
          SMTP_HOST = config.garden.services.mailserver.domain;
          SMTP_FROM = "vaultwarden@${config.garden.domain}";
          SMTP_FROM_NAME = "Vaultwarden";
          SMTP_USERNAME = "vaultwarden@${config.garden.domain}";
          SMTP_SECURITY = "force_tls";
          SMTP_PORT = 465;
          SMTP_AUTH_MECHANISM = "Login";

          SIGNUPS_ALLOWED = false;
          SIGNUPS_VERIFY = true;
          INVITATIONS_ALLOWED = false;
          SHOW_PASSWORD_HINT = false;

          LOG_LEVEL = "warn";
          EXTENDED_LOGGING = true;
          USE_SYS_LOG = true;
        };
      };
    };
  };
}
