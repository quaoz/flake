{pkgs, ...}: {
  # common miscellaneous tools
  # TODO: sort these
  home.packages = with pkgs; [
    launchctl-completion
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
  ];
}
