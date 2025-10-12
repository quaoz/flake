{
  config,
  self,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.pocket-id;

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
      APIKEY_FILE = config.age.secrets.pocket-id-api-key.path;
      CLIENTS_FILE = clientsFile;
      PURGE_CLIENTS = cfg.purgeClients;
    };

    text = builtins.readFile ./manage.sh;
  };

  inherit (self.lib) mkOpt mkOpt';
  inherit (lib) types;
in {
  options.services.pocket-id = {
    purgeClients = lib.mkEnableOption "remove unspecified oidc clients";

    oidc-clients = mkOpt (types.attrsOf (
      types.submodule ({config, ...}: let
        inherit (config._module.args) name;
      in {
        options = {
          id = mkOpt types.str (builtins.hashString "md5" name) "The clients name";

          launchURL = mkOpt' types.str "URL to open when ${name} is launched";
          callbackURLs = mkOpt (types.listOf types.str) [] "Callback urls for ${name}";
          logoutCallbackURLs = mkOpt (types.listOf types.str) [] "Logout callback urls for ${name}";

          isPublic = mkOpt types.bool false "Whether the client is public";
          pkceEnabled = mkOpt types.bool false "Whether the client supports PKCE";
          requiresReauthentication = mkOpt types.bool false "Whether users must authenticate on each authorization";

          secret = {
            user = mkOpt' types.str "The secret owner";
            group = mkOpt' types.str "The secrets group";
          };
        };
      })
    )) {} "OIDC clients to provision";
  };

  config = {
    garden.secrets = {
      gen =
        lib.mapAttrs' (name: clientCfg: {
          name = "${name}-oidc-secret";
          value = clientCfg.secret // {type = "_oidc-secret";};
        })
        cfg.oidc-clients;

      other = lib.optionals cfg.enable [
        {
          inherit (config.services.pocket-id) user group;
          path = "services/pocket-id/api-key.age";
        }
      ];
    };

    systemd.services.pocket-id-manage = lib.mkIf cfg.enable {
      description = "manage pocket-id oidc clients";

      wantedBy = ["multi-user.target"];
      after = ["network.target" "pocket-id.service"];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe script}";
        User = config.services.pocket-id.user;
        Group = config.services.pocket-id.group;
      };
    };
  };
}
