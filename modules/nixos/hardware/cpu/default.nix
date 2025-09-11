{
  lib,
  self,
  ...
}: {
  options.garden.hardware.cpu = self.lib.mkOpt (lib.types.nullOr (lib.types.enum ["intel"])) null "The manufacturer of the systems cpu";
}
