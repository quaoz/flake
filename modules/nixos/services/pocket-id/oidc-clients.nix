{
  config,
  self,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.pocket-id;
  gcfg = config.garden.services.pocket-id;

  clientsFile =
    self.lib.hosts self {}
    |> lib.mapAttrsToList (
      _: hc:
        lib.filterAttrs (
          _: sc:
            sc.enable
            && sc.oidc.enable
        )
        hc.config.garden.services
        |> lib.mapAttrsToList (
          name: sc:
            builtins.removeAttrs sc.oidc ["enable"]
            // {
              inherit (sc.dash) launchURL;
              inherit name;
            }
        )
    )
    |> lib.flatten
    |> builtins.toJSON
    |> builtins.toFile "oidc-clients.json";

  script = pkgs.writeShellApplication {
    name = "pocket-id-manage";
    meta.description = "declarative management of pocket-id OIDC clients";

    runtimeInputs = [
      pkgs.uutils-coreutils-noprefix
      pkgs.jq
      pkgs.xh
    ];

    runtimeEnv = {
      APIKEY_FILE = secrets.pocket-id-api-key.path;
      CLIENTS_FILE = clientsFile;
      PURGE_CLIENTS = cfg.purgeClients;
      POCKET_ID_DOMAIN = gcfg.domain;
    };

    text = builtins.readFile ./manage.sh;
  };

  inherit (config.age) secrets;
in {
  options.services.pocket-id = {
    purgeClients = lib.mkEnableOption "remove unspecified OIDC clients";
  };

  config = {
    garden.secrets = {
      other = lib.optionals gcfg.enable [
        {
          inherit (cfg) user group;
          path = "services/pocket-id/api-key.age";
        }
      ];

      normal =
        lib.filterAttrs (_: sc: sc.enable && sc.oidc.enable) config.garden.services
        |> lib.mapAttrs' (sn: sc: {
          name = "oidc-${sn}";

          value = {
            inherit (sc) group;
            owner = sc.user;

            generator = {
              tags = ["oidc"];

              dependencies.api = secrets.pocket-id-api-key;
              script = {
                pkgs,
                deps,
                decrypt,
                ...
              }: let
                jq = lib.getExe pkgs.jq;
                xh = lib.getExe pkgs.xh;
              in ''
                APIKEY="$(${decrypt} ${lib.escapeShellArg deps.api.file})"
                req() {
                    ${xh} --body --pretty none "$1" "https://${gcfg.domain}/api/$2" "x-api-key:$APIKEY" "''${@:3}"
                }

                client="$(req GET "oidc/clients/${sc.oidc.id}" 2>/dev/null)"
                if [[ "$(${jq} 'has("error")' <<<"$client")" == true ]]; then
                    req POST "oidc/clients" 'name=${sn}' 'id=${sc.oidc.id}' &>/dev/null
                fi

                resp="$(req POST "oidc/clients/${sc.oidc.id}/secret")"
                ${jq} -r '.secret' <<<"$resp"
                unset APIKEY client resp
              '';
            };
          };
        });
    };

    systemd.services.pocket-id-manage = lib.mkIf gcfg.enable {
      description = "manage pocket-id OIDC clients";

      wantedBy = ["multi-user.target"];
      after = ["network.target" "pocket-id.service"];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe script}";
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
