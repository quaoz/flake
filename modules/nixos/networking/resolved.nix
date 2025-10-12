{
  # use systemd-resolved
  # https://tailscale.com/blog/sisyphean-dns-client-linux
  services.resolved = {
    enable = true;
    fallbackDns = [];
  };

  networking.networkmanager.dns = "systemd-resolved";
}
