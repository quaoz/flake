{
  lib,
  self,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (config.garden.networking.addresses) public;
  inherit (config.age) secrets;

  cfg = config.garden.magic.public;
in {
  config = lib.mkIf cfg.enable {
    garden.secrets.root = ["services/magic/dnscontrol-creds.age"];

    systemd.services = {
      dnscontrol = let
        dns = inputs.dnscontrol-nix.lib.buildConfig {
          settings.credsFile = secrets.magic-dnscontrol-creds.path;
          domains =
            builtins.mapAttrs (domain: domainCfg: let
              subdomain = d:
                if d == domain
                then "@"
                else lib.strings.removeSuffix ".${domain}" d;
            in {
              inherit (domainCfg) registrar dnsProvider;
              inherit domain;
              defaultTtl = 30;

              records =
                domainCfg.extraRecords
                ++ (
                  self.lib.hosts self {}
                  |> lib.mapAttrsToList (
                    _: hc:
                      lib.filterAttrs (
                        _: sc:
                          sc.enable
                          && sc.domain != null
                          && sc.proxy.visibility == "public"
                          && lib.hasSuffix domain sc.domain
                      )
                      hc.config.garden.services
                      |> lib.mapAttrsToList (_: sc: [
                        (
                          if public.ipv4.enable
                          then {
                            inherit (public.ipv4) address;
                            type = "a";
                            label = subdomain sc.domain;
                          }
                          else []
                        )
                        (
                          if public.ipv6.enable
                          then {
                            inherit (public.ipv6) address;
                            type = "aaaa";
                            label = subdomain sc.domain;
                          }
                          else []
                        )
                      ])
                  )
                  |> lib.flatten
                );
            })
            cfg.domains;
        };

        dnsconfig = builtins.toFile "dnscontrol.js" dns.outputs.config;
      in {
        description = "configure dns records";
        wantedBy = ["multi-user.target"];
        after = ["network-online.target"];
        wants = ["network-online.target"];

        serviceConfig.Type = "oneshot";
        script = "${lib.getExe pkgs.dnscontrol} push --config ${dnsconfig} --creds ${dns.outputs.creds}";
      };
    };
  };
}
