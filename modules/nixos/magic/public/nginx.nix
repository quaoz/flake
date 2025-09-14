{
  lib,
  self,
  config,
  ...
}: let
  inherit (config.garden.networking.addresses) public;
  cfg = config.garden.magic.public;
in {
  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts =
      self.lib.hosts self {}
      |> self.lib.services "public" (builtins.attrNames cfg.domains)
      |> builtins.map (service: {
        "${service.domain}" = {
          locations."/" =
            {
              proxyPass = "http://${service.hostName}:${builtins.toString service.port}";
            }
            // service.nginxExtraConf;

          # only listen on public addresses
          listenAddresses = builtins.concatLists [
            (lib.optionals public.ipv4.enable [public.ipv4.address])
            (lib.optionals public.ipv6.enable [public.ipv6.address])
          ];
        };
      })
      |> self.lib.safeMerge;
  };
}
