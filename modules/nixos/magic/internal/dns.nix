{
  self,
  lib,
  config,
  ...
}: {
  # configure dns for internal services
  config = lib.mkIf config.garden.services.headscale.enable {
    services.headscale.settings.dns.extra_records =
      self.lib.hosts self {}
      |> lib.mapAttrsToList (
        _: hc: let
          inherit (hc.config.garden.networking.addresses) internal;
        in
          lib.filterAttrs (
            _: sc:
              sc.enable
              && sc.domain != null
              && sc.proxy.visibility == "internal"
          )
          hc.config.garden.services
          |> lib.mapAttrsToList (_: sc: [
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
      )
      |> lib.flatten;
  };
}
