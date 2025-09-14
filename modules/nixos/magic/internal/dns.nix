{
  self,
  lib,
  config,
  ...
}: let
  inherit (config.garden.networking.addresses) internal;
  cfg = config.garden.magic.internal;
in {
  # configure dns for internal services
  config = lib.mkIf (cfg.enable && config.garden.services.headscale.enable) {
    services.headscale.settings.dns.extra_records =
      self.lib.hosts self {}
      |> self.lib.services "internal" [cfg.domain]
      |> builtins.map (sc: [
        (lib.mkIf internal.ipv4.enable {
          name = sc.domain;
          type = "A";
          value = internal.ipv4.address;
        })

        (lib.mkIf internal.ipv6.enable {
          name = sc.domain;
          type = "AAAA";
          value = internal.ipv6.address;
        })
      ])
      |> lib.flatten;
  };
}
