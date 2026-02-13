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

      profiles = {
        server.enable = mkEnableOption "the server profile";
        desktop.enable = mkEnableOption "the desktop profile";
        laptop.enable = mkEnableOption "the laptop profile";

        # service monitoring, see: modules/nixos/monitoring
        monitoring.enable = mkEnableOption "the monitoring profile";

        # persistence, see: modukes/nixos/system/persist
        persistence.enable = mkEnableOption "the persistence profile";

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

      # automatic service proxying, see: modules/nixos/magic
      magic = {};

      # networking configuration, see: modules/nixos/networking
      networking = {};

      # thin wrapper over agenix, see: modules/common/secrets
      secrets = {};

      # services, see: modules/{nixos,darwin}/services
      services = {};

      # system configuration, see: modules/nixos/boot
      system = {};
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
