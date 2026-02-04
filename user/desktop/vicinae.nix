{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  config = lib.mkIf (osConfig.garden.profiles.desktop.enable && pkgs.stdenv.isLinux) {
    programs.vicinae = {
      enable = true;
      systemd.enable = true;

      settings = {
        close_on_focsus_loss = true;
      };
    };
  };
}
