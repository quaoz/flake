{
  lib,
  self,
  config,
  ...
}: let
  inherit (config.garden.networking.addresses) internal;
  cfg = config.garden.magic.internal;
in {
  # setup nginx for services running on this host
  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts =
      self.lib.services "internal" [cfg.domain] {self = {inherit config;};}
      |> builtins.map (sc: {
        "${sc.domain}" = {
          locations."/" =
            {
              proxyPass = "http://127.0.0.1:${builtins.toString sc.port}";
            }
            // sc.nginxExtraConf;

          # only listen on tailscale addresses
          listenAddresses = builtins.concatLists [
            (lib.optionals internal.ipv4.enable [internal.ipv4.address])
            (lib.optionals internal.ipv6.enable [internal.ipv6.address])
          ];
        };
      })
      |> self.lib.safeMerge;
  };
}
