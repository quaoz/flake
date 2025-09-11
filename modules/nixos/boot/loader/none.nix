{
  lib,
  config,
  ...
}: let
  cfg = config.garden.system.boot;
in {
  config = lib.mkIf (cfg.loader == "none") {
    boot.loader.grub.enable = lib.mkForce false;
    boot.loader.systemd-boot.enable = lib.mkForce false;
  };
}
