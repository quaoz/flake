{
  pkgs,
  osConfig,
  lib,
  inputs',
  config,
  ...
}: {
  config =
    lib.mkIf (
      pkgs.stdenv.isLinux
      && osConfig.garden.profiles.desktop.enable
      && osConfig.garden.hardware.audio.enable
      && osConfig.garden.hardware.bluetooth.enable
    ) {
      systemd.user.services.librepods = {
        Unit = {
          Description = "librepods";
          After = [config.wayland.systemd.target];
        };

        Service = {
          ExecStart = lib.getExe inputs'.librepods.packages.default + " --start-minimized";
          Restart = "on-failure";
        };

        Install.WantedBy = [config.wayland.systemd.target];
      };

      home.packages = [
        inputs'.librepods.packages.default
      ];
    };
}
