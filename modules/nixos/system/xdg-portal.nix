{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.garden.profiles.desktop.enable {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      wlr.enable = true;
    };
  };
}
