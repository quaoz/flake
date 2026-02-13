{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  config = lib.mkIf (pkgs.stdenv.isLinux && osConfig.garden.profiles.desktop.enable) {
    programs.vicinae = {
      enable = true;
      systemd.enable = true;

      settings = {
        close_on_focsus_loss = true;
      };
    };
  };
}
