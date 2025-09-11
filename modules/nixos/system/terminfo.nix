{
  lib,
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = lib.optionals config.services.openssh.enable [
    pkgs.ghostty.terminfo
  ];
}
