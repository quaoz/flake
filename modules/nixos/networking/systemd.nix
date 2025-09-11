{lib, ...}: {
  systemd = {
    # allow system to boot without waiting for network
    network.wait-online.enable = false;

    # https://github.com/NixOS/nixpkgs/issues/180175
    # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
    services.NetworkManager-wait-online.enable = lib.mkForce false;
  };
}
