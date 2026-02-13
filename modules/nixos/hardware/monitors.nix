{
  self,
  lib,
  ...
}: let
  monitorType = lib.types.submodule (_: {
    options = {
      order = self.lib.mkOpt lib.types.int 0 "The order of the monitor";
      width = self.lib.mkOpt lib.types.int 1920 "The monitors width in pixels";
      height = self.lib.mkOpt lib.types.int 1080 "The monitors width in pixels";
      refresh-rate = self.lib.mkOpt lib.types.int 60 "The monitors refresh rate";
      scale = self.lib.mkOpt lib.types.float 1.0 "The monitors scale";
      backlightPath = self.lib.mkOpt (lib.types.nullOr lib.types.str) null "Path relative to `/sys/class/backlight` to control this monitors backlight";
    };
  });
in {
  options.garden.hardware.monitors = self.lib.mkOpt (lib.types.attrsOf monitorType) {} "This hosts monitor(s)";
}
