{pkgs, ...}: {
  # common miscellaneous tools
  home.packages = with pkgs; [
    file
    jq
    just
    my-scripts
    rsync
  ];
}
