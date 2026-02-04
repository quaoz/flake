{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.garden.profiles.laptop.enable {
    services.upower = {
      enable = true;
      percentageAction = 3;
      percentageCritical = 5;
      percentageLow = 15;
      criticalPowerAction = "Hibernate";
    };
  };
}
