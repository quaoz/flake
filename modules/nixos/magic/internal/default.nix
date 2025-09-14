{
  lib,
  self,
  config,
  ...
}: let
  cfg = config.garden.magic.internal;
in {
  options.garden.magic.internal = {
    enable =
      lib.mkEnableOption "automatic proxying for internal services"
      // {
        default = config.garden.profiles.server.enable;
      };
    domain = self.lib.mkOpt lib.types.str "internal.${config.garden.domain}" "The domain internal services are made available at";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.garden.networking.addresses.internal.ipv4.enable || config.garden.networking.addresses.internal.ipv6.enable;
        message = ''
          No internal ip addresses have been enabled. You should configure
          `garden.networking.addresses.internal`.
        '';
      }
      {
        assertion = config.garden.services.nginx.enable;
        message = "Nginx must be enabled on `${config.networking.hostName}` for internal proxying to work.";
      }
      {
        assertion = (self.lib.hostsWhere self (_: hc: hc.config.garden.services.headscale.enable) {} |> builtins.attrNames) != [];
        message = "Headscale must be enabled on some host for internal proxying to work.";
      }
    ];
  };
}
