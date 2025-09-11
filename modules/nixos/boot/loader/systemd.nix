{
  lib,
  config,
  ...
}: let
  cfg = config.garden.system.boot;
in {
  config = lib.mkIf (cfg.loader == "systemd-boot") {
    boot.loader.systemd-boot = {
      # use the systemd-boot efi boot loader.
      enable = true;

      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix#L208-L220
      editor = false;

      # only keep last 8 generations
      configurationLimit = 8;

      # use largest available console resolution
      consoleMode = "max";
    };
  };
}
