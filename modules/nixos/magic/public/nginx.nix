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
      |> self.lib.services "public" (builtins.attrNames cfg.domains)
      |> builtins.map (service: {
        "${service.domain}" = {
          locations.${service.location} =
            {
              proxyPass = "http://${service.hostName}:${builtins.toString service.port}";
            }
            // service.nginxExtraConf;
        };
      })
      |> self.lib.safeMerge;
  };
}
