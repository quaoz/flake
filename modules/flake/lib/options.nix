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
  mkServiceOpt = name: {
    enable ? false,
    port ? null,
    host ? "127.0.0.1",
    domain ? null,
    user ? null,
    group ? null,
    depends ? {},
    dash ? {},
    proxy ? {},
    oidc ? {},
    mail ? {},
  }: let
    inherit (lib.types) int str enum attrs listOf bool nullOr;
    inherit (lib) mkEnableOption;

    maybeDomain =
      if domain != null
      then "https://${domain}"
      else null;
  in {
    enable = mkEnableOption "${name}" // {default = enable;};
    port = mkOpt int port "The port for ${name}";
    host = mkOpt str host "The host for ${name}";
    domain = mkOpt (nullOr str) domain "Domain for ${name}";

    # TODO: ensure user and group exist
    user = mkOpt str user "User for ${name}";
    group = mkOpt str group "Group for ${name}";

    # TODO: start service after dependencies? name generally is the same as systemd service name but we
    # can add a service name option to deal with the weird ones, this could get messy though...
    depends = {
      local = mkOpt (listOf str) (depends.local or []) "Services running on this host which ${name} depends on";
      anywhere = mkOpt (listOf str) (depends.anywhere or []) "Services running on any host which ${name} depends on";
    };

    # TODO: lots of services depend on postgres, is it worth adding an option to
    # automatically configure it?
    # postgres = { ... };

    # TODO: persist dirs? current way we do it is kinda ugly + we know the user and group
    # TODO: backups? backup infrastructure is already overdue and it could work nicely with persist dirs
    # TODO: secrets? not so keen on this our secret setup is already pretty messy

    proxy = {
      # TODO: clarify what this means (only disables setting up nginx vhost, not dns or anything else)
      enable = mkEnableOption "automatic nginx configuration for ${name}" // {default = proxy.enable or true;};
      visibility = mkOpt (enum ["local" "internal" "public"]) (proxy.visibility or "local") "The visibility of the ${name} service";
      nginxExtra = mkOpt attrs (proxy.nginxExtra or {}) "Extra config merged with `services.nginx.virtualHosts.\"${domain}\".locations.\"/\"`";
    };

    # TODO: dashboard options, icon, launch url, healthcheck url, ...
    dash = {
      enable = mkEnableOption "dashboard entry for ${name}" // {default = dash.enable or false;};
      icon = mkOpt str (dash.icon or "") "Icon for ${name}";
      launchURL = mkOpt (nullOr str) (dash.launchURL or maybeDomain) "URL to open when ${name} is launched";
      healthURL = mkOpt (nullOr str) (dash.healthURL or maybeDomain) "URL queried to determine the status of ${name}";
      okCodes = mkOpt (listOf int) dash.okCodes or [] "Status codes in addition to 200 to treat as OK";
    };

    oidc = {
      enable = mkEnableOption "OIDC client configuration for ${name}" // {default = oidc.enable or false;};
      id = mkOpt str (builtins.hashString "md5" name) "The OIDC client ID for ${name}";

      callbackURLs = mkOpt (listOf str) (oidc.callbackURLs or []) "Callback urls for ${name}";
      logoutCallbackURLs = mkOpt (listOf str) (oidc.logoutCallbackURLs or []) "Logout callback urls for ${name}";

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
