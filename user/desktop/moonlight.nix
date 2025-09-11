{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # discord client

  # TODO: switch to moonlight module and configuration
  #       https://moonlight-mod.github.io/using/install/#flake
  home.packages = with pkgs;
    lib.optionals osConfig.garden.profiles.desktop.enable [
      (
        discord.override {
          withOpenASAR = true;
          withMoonlight = true;
        }
      )
    ];
}
