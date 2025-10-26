{
  self,
  config,
  lib,
  ...
}: let
  inherit (config.age) secrets;
  cfg = config.garden.services.attic;
in {
  options.garden.services.attic = self.lib.mkServiceOpt "attic" {
    port = 3005;
    host = "0.0.0.0";
    domain = "cache.${config.garden.domain}";
    depends.local = ["postgresql"];

    proxy = {
      visibility = "public";
      nginxExtra.extraConfig = ''
        client_max_body_size 612m;
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    garden = {
      persist.dirs = lib.optionals (config.services.atticd.settings.storage.type == "local") [
        # systemd dynamic user
        "/var/lib/private/atticd"
      ];

      secrets = {
        intermediary = ["services/attic/admin-token.age"];

        normal = {
          attic-server-token = {
            generator.script = "rsa";
            intermediary = true;
          };

          attic-env-file = {
            generator = {
              dependencies.token = secrets.attic-server-token;

              script = {
                pkgs,
                deps,
                decrypt,
                ...
              }: ''
                token="$(${decrypt} ${lib.escapeShellArg deps.token.file})"
                echo "ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64='$(echo -n "$token" | ${lib.getExe' pkgs.coreutils "base64"} -w0)'"
                unset token
              '';
            };
          };
        };
      };
    };

    services = {
      postgresql = {
        ensureDatabases = ["atticd"];
        ensureUsers = [
          {
            name = "atticd";
            ensureDBOwnership = true;
          }
        ];
      };

      atticd = {
        enable = true;
        environmentFile = secrets.attic-env-file.path;

        # https://github.com/zhaofengli/attic/blob/main/server/src/config-template.toml
        settings = {
          listen = "${cfg.host}:${builtins.toString cfg.port}";

          allowed-hosts = ["${cfg.domain}"];
          api-endpoint = "https://${cfg.domain}/";

          database = {
            url = "postgres://atticd?host=/run/postgresql";
            heartbeat = true;
          };

          compression = {
            type = "zstd";
            level = 10;
          };

          storage = {
            type = "local";
            path = "/var/lib/atticd/storage";
          };

          chunking = {
            nar-size-threshold = 64 * 1024;
            min-size = 16 * 1024;
            avg-size = 64 * 1024;
            max-size = 256 * 1024;
          };
        };
      };
    };
  };
}
