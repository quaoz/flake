{
  config,
  self,
  lib,
  ...
}: let
  mkIpAddr = name: {
    enable = lib.mkEnableOption name;
    address = self.lib.mkOpt' lib.types.str "This hosts ${name} address";
    gateway = self.lib.mkOpt' lib.types.str "This hosts ${name} gateway";
    prefix = self.lib.mkOpt' lib.types.str "This hosts ${name} prefix";
  };
in {
  options.garden.networking.addresses = {
    public = {
      configure = lib.mkEnableOption "configure public addresses with networkd";
      device = self.lib.mkOpt' lib.types.str "The device name";

      ipv4 = mkIpAddr "public ipv4";
      ipv6 = mkIpAddr "public ipv6";
    };

    internal = {
      ipv4 = mkIpAddr "public ipv4";
      ipv6 = mkIpAddr "public ipv6";
    };
  };

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
  config.networking = {
    # generate hostId by hashing hostname
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

    enableIPv6 = true;
  };
}
