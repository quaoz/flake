{
  lib,
  self,
  config,
  ...
}: let
  cfg = config.garden.services.atuin;
in {
  options.garden.services.atuin = self.lib.mkServiceOpt "atuin" {
    port = 3001;
    host = "0.0.0.0";
    domain = "atuin.${config.garden.magic.internal.domain}";
    depends.local = ["postgresql"];
    proxy.visibility = "internal";
  };

  config = lib.mkIf cfg.enable {
    services.atuin = {
      inherit (cfg) host port;

      enable = true;
      openRegistration = true;
    };
  };
}
