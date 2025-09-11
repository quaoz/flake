{
  self,
  config,
  ...
}: let
  cfg = config.garden.hardware.disks;
  rootPart = config.disko.devices.disk.main.content.partitions.root.device;
in {
  root = self.lib.safeMerge [
    {
      content = {
        type = "btrfs";
        extraArgs = ["-f"];
      };
    }

    (
      if cfg.partitions.swap.enable
      then {
        end = "-${cfg.partitions.swap.size}";
      }
      else {
        size = "100%";
      }
    )

    (
      if !(cfg.impermanence.enable || cfg.impermanence.future)
      then {
        content = {
          mountOptions = ["compress=zstd" "noatime"];
          mountpoint = "/";
        };
      }
      else {
        content = {
          # create an empty snapshot
          postCreateHook = ''
            mnt=$(mktemp -d)
            mount ${rootPart} "$mnt" -o subvol=/
            trap 'umount $mnt; rm -rf $mnt' EXIT
            btrfs subvolume snapshot -r "$mnt/root" "$mnt/root-blank"
          '';

          subvolumes = {
            "/root" = {
              mountOptions = ["compress=zstd" "noatime"];
              mountpoint = "/";
            };
            "/home" = {
              mountOptions = ["compress=zstd"];
              mountpoint = "/home";
            };
            "/nix" = {
              mountOptions = ["compress=zstd" "noatime"];
              mountpoint = "/nix";
            };
            "${cfg.impermanence.location}" = {
              mountOptions = ["compress=zstd" "noatime"];
              mountpoint = "${cfg.impermanence.location}";
            };
            "/log" = {
              mountOptions = ["compress=zstd" "noatime"];
              mountpoint = "/var/log";
            };
          };
        };
      }
    )
  ];
}
