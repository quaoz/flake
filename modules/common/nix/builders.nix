{
  lib,
  self,
  config,
  ...
}: let
  inherit (config.age) secrets;
in {
  config = {
    garden.secrets.root = [
      "nix/signing-key.age"
      "nix/signing-key-pub.age"
    ];

    # TODO: set ssh knownhosts
    nix = {
      # enable distributed builds
      distributedBuilds = true;

      # collect build machines
      buildMachines =
        self.lib.hostsWhere self (hn: hc: hn != config.networking.hostName && hc.config.garden.services.remote-builder.enable) {}
        |> lib.attrsets.mapAttrsToList (bn: bc: {
          inherit (bc.pkgs.stdenv.hostPlatform) system;
          hostName = bn;

          protocol = "ssh-ng";
          sshUser = "nix-remote";
          sshKey = secrets.ssh-nix-remote-builder.path;

          supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        });

      settings = {
        # sign builds with our key
        secret-key-files = [secrets.nix-signing-key.path];

        # trust builds we signed
        extra-trusted-public-keys = ["nix-remote-0:andMQ/kH0SZ5xn3K+NZexj1OAxp0TZe/u+RX94MVhXg="];
      };
    };
  };
}
