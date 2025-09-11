{
  imports = [
    ../common/system/revision.nix
    ../nixos/system/terminfo.nix
  ];

  # we don't want to alter the iso image itself so we prevent rebuilds
  system.switch.enable = false;
}
