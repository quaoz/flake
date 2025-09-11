{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nix-index-database.homeModules.nix-index];

  # tools for working with nix
  home.packages = with pkgs; [
    alejandra
    nh
    nil
    nurl
    nix-output-monitor
  ];

  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enable = true;
}
