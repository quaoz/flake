{
  pkgs,
  lib,
  ...
}: let
  # installation script based on https://github.com/isabelroses/dotfiles/blob/main/modules/flake/packages/iztaller/iztaller.sh
  easy-install = pkgs.writeShellApplication {
    name = "easy-install";

    runtimeInputs = with pkgs; [
      gum
      parted
    ];

    text = builtins.readFile ./easy-install.sh;

    meta = with lib; {
      description = "NixOS installation script";
      maintainers = with maintainers; [quaoz];
    };
  };
in {
  environment.systemPackages = [
    easy-install
  ];
}
