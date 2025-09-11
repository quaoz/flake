{
  self,
  pkgs,
  lib,
  osConfig,
  ...
}: {
  programs.ghostty = lib.mkIf osConfig.garden.profiles.desktop.enable {
    enable = true;

    # ghostty broken on darwin so use binary
    package = self.lib.ldTernary pkgs pkgs.ghostty pkgs.ghostty-bin;

    settings = {
      font-size = 14;
      window-padding-x = 6;
      window-padding-y = 6;
    };
  };
}
