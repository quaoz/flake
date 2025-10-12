{
  config,
  lib,
  ...
}: let
  cfg = config.garden.monitoring;
in {
  options.garden.monitoring = {
    enable =
      lib.mkEnableOption "monitoring"
      // {
        default = config.garden.profiles.server.enable;
      };
  };

  config = lib.mkIf (!cfg.enable) {
    garden.monitoring = {
      node.enable = lib.mkForce false;
    };
  };
}
