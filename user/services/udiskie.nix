{
  lib,
  osConfig,
  pkgs,
  ...
}: {
  config = lib.mkIf (osConfig.garden.profiles.desktop.enable && pkgs.stdenv.isLinux) {
    services.udiskie = {
      enable = true;
    };
  };
}
