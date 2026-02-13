{
  config,
  lib,
  ...
}: let
  inherit (config.age) secrets;

  isServer = config.garden.profiles.server.enable;
in {
  config = {
    garden = {
      secrets.root = ["services/tailscale/authkey.age"];
      profiles.persistence.dirs = ["/var/lib/tailscale"];
    };

    # trust tailscale interface
    networking.firewall.trustedInterfaces = ["${config.services.tailscale.interfaceName}"];

    services.tailscale = {
      enable = true;
      authKeyFile = secrets.tailscale-authkey.path;

      # advertise servers as exit node
      extraUpFlags =
        [
          "--reset"
          "--operator=${config.me.username}"
          "--login-server=https://${config.garden.services.headscale.domain}"
        ]
        ++ lib.optionals isServer [
          "--advertise-tags"
          "tag:server,tag:exit"
          "--advertise-exit-node"
        ];

      useRoutingFeatures =
        if isServer
        then "both"
        else "client";
    };
  };
}
