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
    visibility ? "local",
    port ? null,
    host ? "127.0.0.1",
    domain ? null,
    extraConfig ? {},
    nginxExtraConf ? {},
  }: let
    inherit (lib) types;
  in
    {
      enable = lib.mkEnableOption "${name}" // {default = enable;};
      visibility = mkOpt (types.enum ["local" "private" "public"]) visibility "The visibility of the ${name} service";
      port = mkOpt (types.nullOr types.int) port "The port for the ${name} service";
      host = mkOpt types.str host "The host for ${name} service";
      domain = mkOpt (types.nullOr types.str) domain "Domain for the ${name} service";
      nginxExtraConf = mkOpt types.attrs nginxExtraConf "Extra config merged with `services.nginx.virtualHosts.\"${domain}\".locations.\"/\"`";
    }
    // extraConfig;
}
