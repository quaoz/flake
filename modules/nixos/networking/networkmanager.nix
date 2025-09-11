{
  networking = {
    networkmanager = {
      # use networkmanager
      enable = true;

      unmanaged = [
        "interface-name:tailscale*"
        "type:bridge"
      ];

      # enable wifi powersaving
      wifi.powersave = true;
    };
  };
}
