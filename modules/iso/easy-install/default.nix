{pkgs, ...}: let
  # installation script based on https://github.com/isabelroses/dotfiles/blob/main/modules/flake/packages/iztaller/iztaller.sh
  easy-install = pkgs.writeShellApplication {
    name = "easy-install";

    runtimeInputs = with pkgs; [
      gum
      parted
    ];

    text = builtins.readFile ./easy-install.sh;
  };
in {
  environment.systemPackages = [
    easy-install
  ];
}
