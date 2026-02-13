{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.garden.profiles.desktop.enable {
    services.greetd = {
      enable = true;
      restart = true;

      settings = let
        sessionData = config.services.displayManager.sessionData.desktops;
        sessionPath = builtins.concatStringsSep ":" [
          "${sessionData}/share/xsessions"
          "${sessionData}/share/wayland-sessions"
        ];
      in {
        default_session = {
          user = "greeter";
          command = builtins.concatStringsSep " " [
            (lib.getExe pkgs.tuigreet)
            "--time"
            "--remember"
            "--remember-user-session"
            "--asterisks"
            "--sessions '${sessionPath}'"
          ];
        };
      };
    };
  };
}
