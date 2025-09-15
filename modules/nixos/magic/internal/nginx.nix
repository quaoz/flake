{
  lib,
  self,
  config,
  ...
}: let
  cfg = config.garden.magic.internal;
in {
  # setup nginx for services running on this host
  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts =
      self.lib.services "internal" [cfg.domain] {self = {inherit config;};}
      |> builtins.map (sc: {
        "${sc.domain}" = {
          locations.${sc.location} =
            {
              proxyPass = "http://127.0.0.1:${builtins.toString sc.port}";
            }
            // sc.nginxExtraConf;

          # only allow access from tailnet
          extraConfig = ''
            allow ${config.garden.services.headscale.prefixes.ipv4};
            allow ${config.garden.services.headscale.prefixes.ipv6};
            deny all;
          '';
        };
      })
      |> self.lib.safeMerge;
  };
}
