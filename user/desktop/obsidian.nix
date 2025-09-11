{
  lib,
  osConfig,
  ...
}: {
  # notes
  programs.obsidian = lib.mkIf osConfig.garden.profiles.desktop.enable {
    enable = true;

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
}
