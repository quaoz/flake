{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.garden.profiles.desktop.enable {
    programs.hyprland.enable = true;
  };
}
