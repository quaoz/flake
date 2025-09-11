{
  lib,
  config,
  ...
}: {
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
  systemd.network.enable = true;

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
