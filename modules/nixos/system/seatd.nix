{config, ...}: {
  services.seatd.enable = config.garden.profiles.desktop.enable;
}
