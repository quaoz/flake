{
  lib,
  pkgs,
  self,
  config,
  ...
}: let
  cfg = config.garden.services.redis;
in {
  options.garden.services.redis = self.lib.mkServiceOpt "redis" {};

  config = lib.mkIf cfg.enable {
    services.redis = {
      package = pkgs.valkey;
    };
  };
}
