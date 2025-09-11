{
  config,
  lib,
  ...
}: let
  cfg = config.garden.hardware.disks;
  rootPart = config.disko.devices.disk.main.content.partitions.root.device;
in {
  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && (cfg.impermanence.enable || cfg.impermanence.future)) {
      fileSystems = {
        "${cfg.impermanence.location}".neededForBoot = true;
        "/var/log".neededForBoot = true;
      };
    })

    (lib.mkIf (cfg.enable && cfg.impermanence.enable) {
      boot.initrd.systemd.services.btrfs-impermanence = {
        description = "restore blank root snapshot";

        wantedBy = ["initrd.target"];
        before = ["sysroot.mount"];

        unitConfig.DefaultDependencies = "no";
        serviceConfig = {
          Type = "oneshot";
          TimeoutStartSec = 180;
        };

        script = ''
          (
              set -euo pipefail

              timeout=0
              udevadm settle || true

              # wait for device to be avaliavble
              while [[ ! -b ${rootPart} ]] && ((timeout++ < 60)); do
                  echo "[impermanence] waiting for ${rootPart} ($timeout/60)"
                  sleep 1
                  udevadm settle || true
              done

              # mount device
              mnt=$(mktemp -d)
              mount -o subvol=/ "${rootPart}" "$mnt"

              front=0
              queue=("$mnt/root")

              # find all subvolumes
              while ((''${#queue[@]} > front)); do
                  while IFS= read -r subvol; do
                      queue+=("$mnt/$subvol")
                  done < <(btrfs subvolume list -o "''${queue[$front]}" | cut -f9 -d' ')
                  ((front++))
              done

              # remove subvolumes
              while ((front-- > 0)); do
                  echo "[impermanence] deleting subvolume ''${queue[$front]}"
                  btrfs subvolume delete "''${queue[$front]}"
              done

              echo "[impermanence] restoring blank snapshot"
              btrfs subvolume snapshot "$mnt/root-blank" "$mnt/root"

              umount "$mnt"
          ) || echo "[impermanence] wipe failed — continuing boot"
        '';
      };
    })
  ];
}
