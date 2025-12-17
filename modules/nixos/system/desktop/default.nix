{
  config,
  self,
  lib,
  ...
}: {
  options.garden.system.desktop = {
    enable = lib.mkEnableOption "desktop environment" // {default = config.garden.profiles.desktop.enable;};
    environment = self.lib.mkOpt (lib.types.enum ["gnome" "cosmic"]) "gnome" "The desktop environment to use";
  };
}
