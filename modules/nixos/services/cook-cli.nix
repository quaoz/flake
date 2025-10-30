{
  self,
  lib,
  config,
  ...
}: let
  cfg = config.garden.services.cook-cli;
in {
  options.garden.services.cook-cli = self.lib.mkServiceOpt "cook-cli" {
    port = 4008;
    domain = "cook.${config.garden.magic.internal.domain}";
    user = "cook-cli";
    group = "cook-cli";

    proxy.visibility = "internal";

    dash = {
      enable = true;
      icon = "sh:cook-cli-light";
    };
  };

  config = lib.mkIf cfg.enable {
    garden.persist.dirs = [
      {
        inherit (cfg) user group;
        directory = config.services.cook-cli.basePath;
      }
    ];

    services.cook-cli = {
      enable = true;
      inherit (cfg) port;
    };
  };
}
