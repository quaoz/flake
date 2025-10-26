{
  lib,
  self,
  config,
  ...
}: let
  cfg = config.garden.magic.public;
in {
  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts =
      self.lib.hosts self {}
      |> lib.mapAttrsToList (
        hn: hc:
          lib.filterAttrs (
            _: sc:
              sc.enable
              && sc.domain != null
              && sc.proxy.enable
              && sc.proxy.visibility == "public"
              && (builtins.any (domain: lib.hasSuffix domain sc.domain) (builtins.attrNames cfg.domains))
          )
          hc.config.garden.services
          |> lib.mapAttrs' (_: sc: {
            name = "${sc.domain}";
            value = {
              locations."/" =
                {
                  proxyPass = "http://${hn}:${builtins.toString sc.port}";
                }
                // sc.proxy.nginxExtra;
            };
          })
      )
      |> self.lib.safeMerge;
  };
}
