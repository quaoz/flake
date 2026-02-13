{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  config = lib.mkIf (pkgs.stdenv.isLinux && osConfig.garden.profiles.desktop.enable) {
    programs.quickshell = {
      enable = true;
      systemd.enable = true;

      package = pkgs.symlinkJoin {
        name = "quickshell-wrapped";
        paths = [
          pkgs.quickshell
          pkgs.kdePackages.qtimageformats
          pkgs.cosmic-icons
        ];
        meta.mainProgram = pkgs.quickshell.meta.mainProgram;
      };
    };

    home.packages = [
      pkgs.qt6.qtdeclarative
      pkgs.quickshell
    ];
  };
}
