{config, ...}: {
  services.udisks2.enable = config.garden.profiles.desktop.enable;
}
