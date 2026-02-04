{config, ...}: {
  security = {
    polkit.enable = true;

    soteria.enable = config.garden.profiles.desktop.enable;
  };
}
