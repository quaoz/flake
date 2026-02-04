{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.garden.profiles.desktop.enable {
    services.gnome = {
      gnome-keyring.enable = true;
      gcr-ssh-agent.enable = false;
    };

    programs.seahorse.enable = true;
  };
}
