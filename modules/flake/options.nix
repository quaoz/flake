{lib, ...}: let
  inherit (lib) mkEnableOption types;
  inherit (import ./lib/options.nix {inherit lib;}) mkOpt';
in {
  # TODO: cleanup/restructure options
  options = {
    me = {
      username = mkOpt' types.str "The username";
      pubkey = mkOpt' types.str "The ssh pubkey";
      email = mkOpt' types.str "The email";
    };

    garden = {
      domain = mkOpt' types.str "The domain";
      pubkey = mkOpt' types.str "This hosts pubkey";

      profiles = {
        server.enable = mkEnableOption "the server profile";
        desktop.enable = mkEnableOption "the desktop profile";

        # this doesn't do anything except flag that this host is an iso so it
        # can be ignored when configuring things like build machines
        iso.enable = mkEnableOption "the iso profile";

        # a very arbitrary option, if set prevents this host from being configured
        # as a remote builder and tells deploy-rs to build the system locally
        # instead of on this host
        slow.enable = mkEnableOption "the slow profile";
      };

      # hardware configuration, see: modules/nixos/hardware
      hardware = {};

      # persistence, see: modukes/nixos/system/persist
      persist = {};

      # automatic service proxying, see: modules/nixos/services/proxy
      proxy = {};

      # thin wrapper over agenix, see: modules/common/secrets
      secrets = {};

      # services, see: modules/{nixos,darwin}/services
      services = {};

      system = {
        # networking configuration, see: modules/nixos/networking
        networking = {};
      };
    };
  };

  config = {
    me = {
      username = "ada";
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6AibH20CO2t0ClO90mELkyEM9cCXUeUYKpZv80v6n0";
    };

    garden = {
      domain = lib.mkDefault "xenia.dog";
    };
  };
}
