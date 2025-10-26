{lib, ...}: rec {
  /**
  create a nixos module option

  # Inputs

  `type`
  : the option type

  `default`
  : the default value when no definition is provided

  `description`
  : the option description

  # Type

  ```nix
  mkOpt :: Type --> Any --> String --> AttrSet
  ```

  # Example

  ```nix
  mkOpt types.str "default" "option description"
  ```
  */
  mkOpt = type: default: description:
    lib.mkOption {inherit type default description;};

  /**
  create a nixos module option

  # Inputs

  `type`
  : the option type

  `description`
  : the option description

  # Type

  ```nix
  mkOpt' :: Type --> String --> AttrSet
  ```

  # Example

  ```nix
  mkOpt' types.str "option description"
  ```
  */
  mkOpt' = type: description:
    lib.mkOption {inherit type description;};

  /**
  helper to quickly create a set of common service configuration options

  # Inputs

  `name`
  : the service name

  `enable`
  : whether to enable the service (default: false)

  `visibility`
  : service visibility level - "local", "private", or "public" (default: "local")

  `port`
  : the service port number (default: null)

  `host`
  : the service host address (default: "127.0.0.1")

  `domain`
  : the service domain name (default: null)

  `extraConfig`
  : additional configuration options to merge (default: {})

  `nginxExtraConf`
  : extra nginx configuration for the service (default: {})

  # Type

  ```nix
  mkServiceOpt :: String -> AttrSet -> AttrSet
  ```

  # Example

  ```nix
  mkServiceOpt "myservice" { enable = true; port = 3000; visibility = "public"; }
  => {
    enable = { _type = "option"; default = true; description = "Whether to enable myservice."; };
    visibility = { _type = "option"; type = ...; default = "public"; description = "The visibility of the myservice service"; };
    port = { _type = "option"; type = ...; default = 3000; description = "The port for the myservice service"; };
    ...
  }
  ```
  */
  mkServiceOptOld = name: {
    enable ? false,
    proxy ? true,
    visibility ? "local",
    dependsLocal ? [],
    dependsAnywhere ? [],
    port ? null,
    host ? null,
    domain ? null,
    nginxExtraConf ? {},
  }: let
    inherit (lib) types;
  in {
    enable = lib.mkEnableOption "${name}" // {default = enable;};
    proxy = lib.mkEnableOption "proxy ${name}" // {default = proxy;};
    visibility = mkOpt (types.enum ["local" "internal" "public"]) visibility "The visibility of the ${name} service";

    depends = {
      local = mkOpt (types.listOf types.str) dependsLocal "List of local services which ${name} depends on";
      anywhere = mkOpt (types.listOf types.str) dependsAnywhere "List of services running on any host which ${name} depends on";
    };

    domain = mkOpt (types.nullOr types.str) domain "Domain for the ${name} service";
    port = mkOpt (types.nullOr types.int) port "The port for the ${name} service";
    host = mkOpt types.str host "The host for ${name} service";
    nginxExtraConf = mkOpt types.attrs nginxExtraConf "Extra config merged with `services.nginx.virtualHosts.\"${domain}\".locations.\"/\"`";
  };

  mkServiceOpt = name: {
    enable ? false,
    port ? null,
    host ? "127.0.0.1",
    domain ? null,
    user ? null,
    group ? null,
    depends ? {},
    proxy ? {},
    oidc ? {},
    mail ? {},
  }: let
    inherit (lib.types) int str enum attrs listOf bool nullOr;
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "${name}" // {default = enable;};
    port = mkOpt int port "The port for ${name}";
    host = mkOpt str host "The host for ${name}";
    domain = mkOpt (nullOr str) domain "Domain for ${name}";

    user = mkOpt str user "User for ${name}";
    group = mkOpt str group "Group for ${name}";

    depends = {
      local = mkOpt (listOf str) (depends.local or []) "Services running on this host which ${name} depends on";
      anywhere = mkOpt (listOf str) (depends.anywhere or []) "Services running on any host which ${name} depends on";
    };

    proxy = {
      enable = mkEnableOption "automatic nginx configuration for ${name}" // {default = proxy.enable or true;};
      visibility = mkOpt (enum ["local" "internal" "public"]) (proxy.visibility or "local") "The visibility of the ${name} service";
      nginxExtra = mkOpt attrs (proxy.nginxExtra or {}) "Extra config merged with `services.nginx.virtualHosts.\"${domain}\".locations.\"/\"`";
    };

    oidc = {
      enable = mkEnableOption "OIDC client configuration for ${name}" // {default = oidc.enable or oidc != {};};
      id = mkOpt str (builtins.hashString "md5" name) "The OIDC client ID for ${name}";

      launchURL = mkOpt str oidc.launchURL or domain "URL to open when ${name} is launched";
      callbackURLs = mkOpt (listOf str) oidc.callbackURLs or [] "Callback urls for ${name}";
      logoutCallbackURLs = mkOpt (listOf str) oidc.logoutCallbackURLs or [] "Logout callback urls for ${name}";

      isPublic = mkOpt bool (oidc.isPublic or false) "Whether the client is public";
      pkceEnabled = mkOpt bool (oidc.pkceEnabled or false) "Whether the client supports PKCE";
      requiresReauthentication = mkOpt bool (oidc.requiresReauthentication or false) "Whether users must authenticate on each authorization";
    };

    mail = {
      enable = mkEnableOption "mail account for ${name}" // {default = mail.enable or false;};
      account = mkOpt str (mail.account or name) "The mail account name for ${name}";
      sendOnly = mkOpt bool (mail.sendOnly or true) "Whether the mail account should be send-only";
    };
  };

  mkMonitorOpt = name: {
    enable,
    port,
  }: {
    enable = lib.mkEnableOption "${name} monitoring" // {default = enable;};
    port = mkOpt lib.types.int port "The port for ${name} metrics";
  };
}
