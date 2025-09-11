{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.stylix.homeModules.stylix];

  stylix = {
    enable = true;

    targets.firefox.profileNames = ["default"];

    base16Scheme = "${pkgs.base16-schemes}/share/themes/mountain.yaml";

    # TODO: add fonts from old flake
    fonts = {
      serif = {
        package = pkgs.b612;
        name = "b612";
      };

      sansSerif = {
        package = pkgs.b612;
        name = "b612";
      };

      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
