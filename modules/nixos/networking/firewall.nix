{config, ...}: {
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [];
    allowedUDPPorts = [];

    allowedTCPPortRanges = [];
    allowedUDPPortRanges = [];

    # let servers be pinged
    allowPing = config.garden.profiles.server.enable;

    # smaller log
    logRefusedConnections = false;
  };
}
