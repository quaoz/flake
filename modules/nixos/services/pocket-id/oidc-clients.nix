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
    self.lib.hostsWhere self (_: hc: hc.config.services.pocket-id.oidc-clients != {}) {}
    |> lib.mapAttrsToList (_: hc: hc.config.services.pocket-id.oidc-clients)
    |> self.lib.safeMerge
    |> lib.mapAttrsToList (
      name: clientCfg: (builtins.removeAttrs clientCfg ["secret"]) // {inherit name;}
    )
    |> builtins.toJSON
    |> builtins.toFile "oidc-clients.json";

  script = pkgs.writeShellApplication {
    name = "pocket-id-manage";
    meta.description = "declarative management of pocket-id oidc clients";

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

  inherit (self.lib) mkOpt mkOpt';
  inherit (config.age) secrets;
  inherit (lib) types;
in {
  options.services.pocket-id = {
    purgeClients = lib.mkEnableOption "remove unspecified oidc clients";

    oidc-clients = mkOpt (types.attrsOf (
      types.submodule ({config, ...}: let
        inherit (config._module.args) name;
      in {
        options = {
          id = mkOpt types.str (builtins.hashString "md5" name) "The clients id";

          launchURL = mkOpt' types.str "URL to open when ${name} is launched";
          callbackURLs = mkOpt (types.listOf types.str) [] "Callback urls for ${name}";
          logoutCallbackURLs = mkOpt (types.listOf types.str) [] "Logout callback urls for ${name}";

          isPublic = mkOpt types.bool false "Whether the client is public";
          pkceEnabled = mkOpt types.bool false "Whether the client supports PKCE";
          requiresReauthentication = mkOpt types.bool false "Whether users must authenticate on each authorization";

          secret = {
            user = mkOpt' types.str "The secret owner";
            group = mkOpt' types.str "The secrets group";
            path = mkOpt' types.path "Path to the oidc secret";
          };
        };

        config.secret = {
          inherit (secrets."_oidc-${name}") path;
        };
      })
    )) {} "OIDC clients to provision";
  };

  config = {
    garden.secrets = {
      normal =
        lib.mapAttrs' (name: clientCfg: {
          name = "_oidc-${name}";
          value = {
            inherit (clientCfg.secret) group;
            owner = clientCfg.secret.user;

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

                client="$(req GET "oidc/clients/${clientCfg.id}" 2>/dev/null)"
                if [[ "$(${jq} 'has("error")' <<<"$client")" == true ]]; then
                    req POST "oidc/clients" 'name=${name}' 'id=${clientCfg.id}' &>/dev/null
                fi

                resp="$(req POST "oidc/clients/${clientCfg.id}/secret")"
                ${jq} -r '.secret' <<<"$resp"
              '';
            };
          };
        })
        cfg.oidc-clients;

      other = lib.optionals gcfg.enable [
        {
          inherit (cfg) user group;
          path = "services/pocket-id/api-key.age";
        }
      ];
    };

    systemd.services.pocket-id-manage = lib.mkIf gcfg.enable {
      description = "manage pocket-id oidc clients";

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
