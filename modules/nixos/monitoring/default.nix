{
  config,
  lib,
  ...
}: let
  cfg = config.garden.profiles.monitoring;
in {
  config = lib.mkIf (!cfg.enable) {
    garden.profiles.monitoring = {
      node.enable = lib.mkForce false;
      blocky.enable = lib.mkForce false;
      fail2ban.enable = lib.mkForce false;
    };
  };
}
