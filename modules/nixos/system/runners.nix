{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.garden.profiles.desktop.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    programs.nix-ld = {
      enable = true;
    };
  };
}
