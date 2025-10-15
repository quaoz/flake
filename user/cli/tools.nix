{pkgs, ...}: {
  # common miscellaneous tools
  # TODO: sort these
  home.packages = with pkgs; [
    file
    jq
    rsync
    tree
    unzip
    gum
    coreutils
    just
    tokei
    lldb
    my-scripts
  ];
}
