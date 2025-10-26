{
  lib,
  config,
  ...
}: let
  cfg = config.garden.magic.internal;
in {
  # setup nginx for services running on this host
  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts =
      lib.filterAttrs (
        _: sc:
          sc.enable
          && sc.domain != null
          && sc.proxy.enable
          && sc.proxy.visibility == "internal"
      )
      config.garden.services
      |> lib.mapAttrs' (_: sc: {
        name = "${sc.domain}";

        value = {
          locations."/" =
            {
              proxyPass = "http://127.0.0.1:${builtins.toString sc.port}";
            }
            // sc.proxy.nginxExtra;

          # only allow access from tailnet
          extraConfig = ''
            allow ${config.garden.services.headscale.prefixes.v4};
            allow ${config.garden.services.headscale.prefixes.v6};
            deny all;
          '';
        };
      });
  };
}
