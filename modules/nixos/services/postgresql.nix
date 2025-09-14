{
  lib,
  self,
  config,
  pkgs,
  ...
}: let
  cfg = config.garden.services.postgresql;
in {
  options.garden.services.postgresql = self.lib.mkServiceOpt "postgresql" {};

  config = lib.mkIf cfg.enable {
    garden.persist.dirs = [
      {
        user = "postgresql";
        group = "postgresql";
        directory = config.services.postgresql.dataDir;
      }
    ];

    services.postgresql = {
      enable = true;
      enableTCPIP = false;

      package = pkgs.postgresql_17;
    };
  };
}
