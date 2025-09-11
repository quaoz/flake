{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}: let
  inherit (osConfig.users.users.${osConfig.me.username}) home;

  zed = config.programs.zed-editor;
in {
  home.sessionVariables = {
    EDITOR =
      if zed.enable
      then "${lib.getExe zed.package} --wait --new"
      else "${lib.getExe pkgs.vim}";

    FLAKE = "${home}/.config/flake";
    NH_FLAKE = "${home}/.config/flake";
  };
}
