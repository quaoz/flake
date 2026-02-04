{
  lib,
  self,
  config,
  ...
}: let
  cfg = config.garden.services.headscale;
in {
  config = lib.mkIf cfg.enable {
    services.headscale.settings.dns = {
      nameservers.global =
        self.lib.hostsWhere self (_: hc: hc.config.garden.services.blocky.enable) {}
        |> lib.mapAttrsToList (_: hc: let
          inherit (hc.config.garden.networking.addresses) internal;
        in [
          (lib.optionals internal.ipv4.enable [internal.ipv4.address])
          (lib.optionals internal.ipv6.enable [internal.ipv6.address])
        ])
        |> lib.flatten;

      base_domain = config.garden.magic.internal.domain;
      search_domains = [config.garden.magic.internal.domain];
    };
  };
}
