{
  self,
  pkgs,
  ...
}: {
  system = {
    stateVersion = self.lib.ldTernary pkgs "25.05" 6;

    # set system revision
    configurationRevision = self.shortRev or self.dirtyShortRev or "dirty";
  };
}
