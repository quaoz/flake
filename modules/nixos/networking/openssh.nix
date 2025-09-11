{
  config,
  lib,
  ...
}: let
  inherit (config.me) username pubkey;
in {
  services.openssh = {
    enable = true;
    allowSFTP = true;

    banner = let
      # wildly unnecessary
      line =
        lib.stringLength username
        |> builtins.genList (_: "─")
        |> lib.concatStrings;
    in ''
      ┌┬─${line}──────────┐
      ││ ${lib.toUpper username} NETWORKS │
      └┴─${line}──────────┘
      ${config.system.name} @ ${config.system.configurationRevision}
    '';

    extraConfig = builtins.concatStringsSep "\n" [
      (
        # disable banner for remote builder
        lib.optionalString config.garden.services.remote-builder.enable ''
          Match User nix-remote
            Banner "none"
        ''
      )
    ];

    hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
      }
    ];

    settings = {
      # ciphers and keying
      KexAlgorithms = [
        "curve25519-sha256@libssh.org"
        "curve25519-sha256"
      ];

      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];

      Macs = [
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-512-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];

      # no root login
      PermitRootLogin = "no";

      # only allow key based authentication
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      PubkeyAuthentication = "yes";
      ChallengeResponseAuthentication = "no";
      UsePAM = false;

      UseDns = false;
      X11Forwarding = false;
    };
  };

  users.users.${username}.openssh.authorizedKeys.keys = [pubkey];
}
