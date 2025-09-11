{
  inputs,
  lib,
  self,
  config,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption;
  inherit (self.lib) mkOpt';

  mkPartition = name: size: default: {
    enable = mkOption {
      inherit default;
      description = "Whether to enable the ${name} partition";
      type = types.bool;
    };
    size = mkOption {
      default = size;
      description = "The size of the ${name} partition";
      type = types.strMatching "[0-9]+[KMGTP]?";
    };
  };

  cfg = config.garden.hardware.disks;
in {
  options.garden.hardware.disks = {
    enable = mkEnableOption "default disk configuration";
    device = mkOpt' types.str "The device to format and partition";

    impermanence = {
      enable = mkEnableOption "BTRFS setup for impermanence";
      # TODO: better explanation
      future =
        mkEnableOption "BTRFS setup for future impermanence use"
        // {
          default = true;
        };
      location =
        self.lib.mkOpt (lib.types.pathWith {
          absolute = true;
          inStore = false;
        })
        config.garden.persist.location "Where to store state";
    };

    partitions = {
      boot = mkPartition "boot" "1M" (config.garden.system.boot.loader == "grub");
      esp = mkPartition "esp" "512M" true;
      swap = mkPartition "swap" "8G" true;
    };
  };

  imports = [inputs.disko.nixosModules.disko];

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.impermanence.enable -> config.garden.persist.enable;
        message = ''
          Impermanence is enabled but persistence isn't. Nothing on the root
          subvolume will persist.

          You should either:
            - enable `garden.persist.enable`
            - or disable `garden.hardware.disks.impermanence.enable`
        '';
      }
      {
        assertion = config.garden.persist.enable -> cfg.impermanence.enable;
        message = ''
          Persistence is enabled without disk support. Your root partition is
          not being cleared between reboots.

          You should either:
            - enable `garden.hardware.disks.impermanence.enable`
            - or disable `garden.hardware.disks.enable`
        '';
      }
      {
        assertion = config.garden.persist.location == cfg.impermanence.location;
        message = ''
          Persistence and impermenance are using different locations, ${config.garden.persist.location}
          and ${cfg.impermanence.location} respectively.

          You should omit `garden.hardware.disks.impermanence.location` to use
          the same value as `garden.persist.location`.
        '';
      }
    ];

    disko.devices = {
      disk = {
        main = {
          type = "disk";
          inherit (cfg) device;

          content = {
            type = "gpt";
            partitions = self.lib.harvest {inherit config self lib;} ./_partitions;
          };
        };
      };
    };
  };
}
