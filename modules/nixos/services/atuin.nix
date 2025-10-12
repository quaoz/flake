{
  lib,
  self,
  config,
  ...
}: let
  cfg = config.garden.services.atuin;
in {
  options.garden.services.atuin = self.lib.mkServiceOpt "atuin" {
    visibility = "internal";
    dependsLocal = ["postgresql"];
    port = 3001;
    host = "0.0.0.0";
    domain = "atuin.${config.garden.magic.internal.domain}";
  };

  config = lib.mkIf cfg.enable {
    services.atuin = {
      inherit (cfg) host port;

      enable = true;
      openRegistration = true;
    };
  };
}
