{
  lib,
  config,
  ...
}: let
  cfg = config.garden.networking.addresses.public;
in {
  networking = {
    # disable global dhcp
    useDHCP = lib.mkForce false;
    dhcpcd.enable = lib.mkForce false;

    # `useNetworkd` will attempt to translate some other networking options into
    # something networkd will understand, we don't need this and would rather
    # define our setup in native networkd configuration
    #
    # see: https://wiki.nixos.org/wiki/Systemd/networkd#Enabling
    useNetworkd = lib.mkForce false;
  };

  # enable networkd
  systemd.network = {
    enable = true;

    networks."10-${cfg.device}" = lib.mkIf cfg.configure {
      matchConfig.Name = "${cfg.device}";
      address = builtins.concatLists [
        (lib.optionals cfg.ipv4.enable ["${cfg.ipv4.address}/${cfg.ipv4.prefix}"])
        (lib.optionals cfg.ipv6.enable ["${cfg.ipv6.address}/${cfg.ipv6.prefix}"])
      ];
      routes = [
        (lib.mkIf cfg.ipv4.enable {Gateway = cfg.ipv4.gateway;})
        (lib.mkIf cfg.ipv6.enable {Gateway = cfg.ipv4.gateway;})
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # as `useNetworkd` is disabled using any of these options will fallback to
  # scripted networking, to prevent this we fail if any of them are not empty
  #
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/tasks/network-interfaces-systemd.nix
  assertions =
    [
      "bonds"
      "bridges"
      "defaultGateway"
      "defaultGateway6"
      "defaultGatewayWindowSize"
      "greTunnels"
      "interfaces"
      "ipips"
      "macvlans"
      "sits"
      "fooOverUDP"
      "vlans"
      "vswitches"
      "wlanInterfaces"
    ]
    |> builtins.map (x: {
      assertion = config.networking.${x} == {} || config.networking.${x} == [] || config.networking.${x} == null;
      message = "`networking.${x}` is being used, use networkd instead";
    });
}
