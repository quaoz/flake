{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config.home) homeDir;
  inherit (config.programs) zed-editor;
in {
  home.sessionVariables = {
    EDITOR =
      if zed-editor.enable
      then "${lib.getExe zed-editor.package} --wait --new"
      else "${lib.getExe pkgs.vim}";

    FLAKE = "${homeDir}/.config/flake";
    NH_FLAKE = "${homeDir}/.config/flake";
  };
}
