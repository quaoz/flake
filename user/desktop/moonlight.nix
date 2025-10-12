{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # discord client
  config = lib.mkIf osConfig.garden.profiles.desktop.enable {
    home.packages = [
      (pkgs.discord.override {
        withOpenASAR = true;
        withMoonlight = true;
      })
    ];
  };
}
