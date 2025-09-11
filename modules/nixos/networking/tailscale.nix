{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.age) secrets;

  isServer = config.garden.profiles.server.enable;
in {
  config = {
    garden = {
      secrets.root = ["services/tailscale/authkey.age"];
      persist.dirs = ["/var/lib/tailscale"];
    };

    networking.firewall = {
      # allow tailscale UDP port through firewall
      allowedUDPPorts = [config.services.tailscale.port];

      # strict filtering breaks tailscale exit node
      checkReversePath = "loose";

      # trust tailscale interface
      trustedInterfaces = ["${config.services.tailscale.interfaceName}"];
    };

    environment.systemPackages = with pkgs; [
      tailscale
    ];

    services.tailscale = {
      enable = true;
      authKeyFile = secrets.tailscale-authkey.path;

      # advertise servers as exit node
      extraUpFlags = lib.optionals isServer ["--advertise-exit-node"];
      useRoutingFeatures =
        if isServer
        then "server"
        else "client";
    };
  };
}
