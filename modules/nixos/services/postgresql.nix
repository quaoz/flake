{
  lib,
  self,
  config,
  pkgs,
  ...
}: let
  cfg = config.garden.services.postgresql;
in {
  options.garden.services.postgresql = self.lib.mkServiceOpt "postgresql" {
    port = 5432;
    user = "postgresql";
    group = "postgresql";
  };

  config = lib.mkIf cfg.enable {
    garden.profiles.persistence.dirs = [
      {
        directory = config.services.postgresql.dataDir;
        inherit (cfg) user group;
      }
    ];

    services.postgresql = {
      enable = true;
      enableTCPIP = false;

      package = pkgs.postgresql_17;

      settings = {
        inherit (cfg) port;
      };
    };
  };
}
