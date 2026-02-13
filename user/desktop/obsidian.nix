{
  lib,
  osConfig,
  ...
}: {
  # notes
  config = lib.mkIf osConfig.garden.profiles.desktop.enable {
    stylix.targets.obsidian.vaultNames = ["uni"];

    programs.obsidian = {
      enable = true;

      vaults = {
        uni = {
          target = "Documents/uni";
        };
      };

      defaultSettings = {
        app = {
          alwaysUpdateLinks = true;
          newFileLocation = "current";
          readableLineLength = true;
          showLineNumber = true;
          showUnsupportedFiles = true;
          vimMode = true;
        };
      };
    };
  };
}
