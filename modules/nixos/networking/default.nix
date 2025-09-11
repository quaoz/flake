{config, ...}: {
  # TLDR:
  #
  # iwd              - wireless
  # networkd         - devices
  # networkmanager   - (also) devices
  # systemd-resolved - dns
  #
  # networkd or networkmanager? in general:
  #   - networkd for static connections (servers)
  #   - nm for connections which vary often (wifi)
  #   - also see: https://wiki.nixos.org/wiki/Systemd/networkd#When_to_use
  #
  # we disable a lot of `networking` options, see: ./networkd.nix for an explanation
  networking = {
    # generate hostId by hashing hostname
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

    enableIPv6 = true;
  };
}
