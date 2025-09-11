# TODO: document this better b4 i forget and general cleanup
{
  lib,
  self,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (config.age) secrets;

  # collect all services for a domain we're proxying
  services =
    self.lib.hosts self {}
    |> builtins.attrValues
    |> builtins.map (
      host:
        host.config.garden.services
        |> lib.filterAttrs (
          _: sc:
            sc.enable
            && (sc.visibility == "public")
            && (builtins.any (domain: lib.hasSuffix domain sc.domain) (builtins.attrNames cfg.domains))
        )
        |> lib.mapAttrsToList (name: sc: {
          inherit (host.config.networking) hostName;
          inherit (sc) domain port nginxExtraConf;
          inherit name;
        })
    )
    |> lib.flatten;

  domainType = lib.types.submodule ({config, ...}: let
    domain = config._module.args.name;
  in {
    options = {
      registrar = self.lib.mkOpt' lib.types.str "The registrar for ${domain}";
      dnsProvider = self.lib.mkOpt' lib.types.str "The dns provider for ${domain}";

      ipv4 = {
        enable = lib.mkEnableOption "IPv4";
        address = self.lib.mkOpt' lib.types.str "The IPv4 address for ${domain}";
      };

      ipv6 = {
        enable = lib.mkEnableOption "IPv6";
        address = self.lib.mkOpt' lib.types.str "The IPv6 address for ${domain}";
      };
    };
  });

  cfg = config.garden.proxy;
in {
  # can't be under services or it tries to evaluate itself
  # TODO: move it somewhere nicer? change garden.services?
  options.garden.proxy = {
    enable = lib.mkEnableOption "proxy";
    domains = self.lib.mkOpt (lib.types.attrsOf domainType) {} "The domains to be proxied";
  };

  config = lib.mkIf cfg.enable {
    # check only one host is proxying each domain
    assertions = let
      overlap =
        self.lib.hostsWhere self (hn: hc: hn != config.networking.hostName && hc.config.garden.proxy.enable) {}
        |> builtins.attrValues
        |> builtins.map (host: builtins.attrNames host.config.garden.proxy.domains)
        |> lib.flatten
        |> builtins.filter (domain: builtins.hasAttr domain cfg.domains);
    in [
      {
        assertion = builtins.length overlap == 0;
        message = "Other hosts configured as proxies for: ${builtins.concatStringsSep ", " overlap}";
      }
    ];

    garden.secrets.root = ["services/proxy/dnscontrol-creds.age"];

    services.nginx.virtualHosts =
      builtins.map (service: {
        "${service.domain}".locations."/" =
          {
            proxyPass = "http://${service.hostName}:${builtins.toString service.port}";
          }
          // service.nginxExtraConf;
      })
      services
      |> self.lib.safeMerge;

    systemd.services.dnscontrol = let
      dns = inputs.dnscontrol-nix.lib.buildConfig {
        settings.credsFile = secrets.proxy-dnscontrol-creds.path;
        domains =
          builtins.mapAttrs (domain: domainCfg: {
            inherit (domainCfg) registrar dnsProvider;
            inherit domain;
            defaultTtl = 30;

            records =
              builtins.filter (service: lib.hasSuffix domain service.domain) services
              |> builtins.map (
                service: let
                  subdomain =
                    if service.domain == domain
                    then "@"
                    else lib.strings.removeSuffix ".${domain}" service.domain;
                in [
                  (
                    if domainCfg.ipv4.enable
                    then {
                      inherit (domainCfg.ipv4) address;
                      type = "a";
                      label = subdomain;
                    }
                    else []
                  )
                  (
                    if domainCfg.ipv6.enable
                    then {
                      inherit (domainCfg.ipv6) address;
                      type = "aaaa";
                      label = subdomain;
                    }
                    else []
                  )
                ]
              )
              |> lib.flatten;
          })
          cfg.domains;
      };

      dnsconfig = builtins.toFile "dnscontrol.js" dns.outputs.config;
    in {
      description = "configure dns records";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig.Type = "oneshot";
      script = "${lib.getExe pkgs.dnscontrol} push --config ${dnsconfig} --creds ${dns.outputs.creds}";
    };
  };
}
