{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.garden.profiles.desktop.enable {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
