{
  lib,
  osConfig,
  ...
}: {
  # discord client
  programs.vesktop = lib.mkIf osConfig.garden.profiles.desktop.enable {
    enable = true;
  };
}
