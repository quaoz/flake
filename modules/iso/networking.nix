{
  lib,
  config,
  ...
}: let
  inherit (config.me) pubkey;
in {
  # TODO: this is definitely overkill, we only need a minimal networking setup
  imports = [
    ../nixos/networking/default.nix
    ../nixos/networking/iwd.nix
    ../nixos/networking/networkd.nix
    ../nixos/networking/networkmanager.nix
    ../nixos/networking/resolved.nix
    ../nixos/networking/systemd.nix
  ];

  # enable ssh
  systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
  users.users.root.openssh.authorizedKeys.keys = [pubkey];
}
