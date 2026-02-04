{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.garden.profiles.laptop.enable {
    services.tuned = {
      enable = true;
    };
  };
}
