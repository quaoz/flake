{lib, ...}: let
  services = visibility: domains: hosts:
    hosts
    |> lib.mapAttrsToList (
      _: hc:
        hc.config.garden.services
        |> lib.filterAttrs (
          _: sc:
            sc.enable
            && (sc.visibility == visibility)
            && (builtins.any (domain: lib.hasSuffix domain sc.domain) domains)
        )
        |> lib.mapAttrsToList (name: sc: {
          inherit (hc.config.networking) hostName;
          inherit (sc) domain port nginxExtraConf;
          inherit name;
        })
    )
    |> lib.flatten;
in {
  inherit services;
}
