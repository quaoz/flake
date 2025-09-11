{
  config,
  lib,
  pkgs,
  ...
}: let
  # WATCH: https://github.com/nix-community/stylix/issues/560
  #        https://github.com/nix-community/home-manager/pull/6045
  style = config.lib.stylix.colors {
    template = ./template.mustache;
    extension = "yml";
  };

  lsColors = builtins.readFile (
    pkgs.runCommand "vivid-ls-colors" {} ''
      ${lib.getExe pkgs.vivid} generate ${style} > $out
    ''
  );
in {
  options.stylix.targets.vivid.enable = config.lib.stylix.mkEnableTarget "vivid" true;

  config = lib.mkIf (config.stylix.enable && config.stylix.targets.vivid.enable) {
    home.sessionVariables = {
      LS_COLORS = "${lsColors}";
    };
  };
}
