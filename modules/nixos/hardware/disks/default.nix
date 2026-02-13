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
      future = mkEnableOption "BTRFS setup for impermanence without actually enabling impermanence" // {default = true;};

      location =
        self.lib.mkOpt (lib.types.pathWith {
          absolute = true;
          inStore = false;
        })
        config.garden.profiles.persistence.location "Where to store state";
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
        assertion = cfg.impermanence.enable -> config.garden.profiles.persistence.enable;
        message = ''
          Disk impermanence is enabled without the persistence profile. Nothing
          on the root subvolume will persist.

          To use impermanence enable `garden.profiles.persistence`, otherwise
          disable `garden.hardware.disks.impermanence`.
        '';
      }
      {
        assertion = config.garden.profiles.persistence.enable -> cfg.impermanence.enable;
        message = ''
          The persistence profile is enabled without disk support. Your root
          partition is not being cleared between reboots.

          To use impermanence enable `garden.hardware.disks.impermanence`,
          otherwise disable `garden.profiles.persistence`.
        '';
      }
      {
        assertion = config.garden.profiles.persistence.location == cfg.impermanence.location;
        message = ''
          Persistence and impermenance are using different locations:
            - ${config.garden.profiles.persistence.location}
            - ${cfg.impermanence.location}

          You should omit `garden.hardware.disks.impermanence.location` to use
          the same value as `garden.profiles.persistence.location`.
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
