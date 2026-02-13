{
  config,
  lib,
  pkgs,
  ...
}: {
  security = {
    pam = {
      # https://wiki.nixos.org/wiki/Yubikey
      # https://joinemm.dev/blog/yubikey-nixos-guide
      u2f.settings = lib.mkIf config.garden.hardware.yubikey.enable {
        cue = true;
        origin = "pam://yubikey";

        # nix run nixpkgs#pam_u2f -- --pin-verification --origin pam://yubikey
        authfile =
          pkgs.writeText "u2f-mappings"
          "${config.me.username}:luC2WDEM54XrW6eYYKIG2YEDZXuV78lgesA0GA6klfHe98Cip/fXru+64TqROpBETZxdLB6ThwbT1AAqbU496g==,eCKjK8K8gtwGqViD74PniYXYgE0n1mBTB4FjElIgNf85zg+PN8MyUdzLBCVJk0t/qVvFnywztB6h2vmCSrR+hQ==,es256,+presence+pin";
      };

      # use ssh keys to authenticate when on a remote connection
      sshAgentAuth.enable = true;

      services = {
        sudo = {
          u2fAuth = config.garden.hardware.yubikey.enable;
          sshAgentAuth = true;
        };

        sudo-rs = {
          u2fAuth = config.garden.hardware.yubikey.enable;
          sshAgentAuth = true;
        };

        login = {
          u2fAuth = config.garden.hardware.yubikey.enable;
          enableGnomeKeyring = true;
        };

        greetd = {
          u2fAuth = config.garden.hardware.yubikey.enable;
          enableGnomeKeyring = true;
        };

        tuigreet = {
          u2fAuth = config.garden.hardware.yubikey.enable;
          enableGnomeKeyring = true;
        };
      };
    };
  };
}
