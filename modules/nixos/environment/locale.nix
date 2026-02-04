{config, ...}: {
  time = {
    timeZone =
      if config.garden.profiles.server.enable
      then "UTC"
      else "Europe/London";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = "en_GB.UTF-8";
  };
}
