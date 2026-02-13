{
  inputs,
  inputs',
  pkgs,
  ...
}: {
  imports = [inputs.nix-index-database.homeModules.nix-index];

  # tools for working with nix
  home.packages = with pkgs; [
    # formatter
    alejandra

    # cli helper
    nh
    # nicer nix output
    nix-output-monitor

    # package creation helpers
    nurl
    nix-init

    # lockfile linter
    inputs'.locker.packages.locker
    # lockfile viewer
    nix-melt
  ];

  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enable = true;
}
