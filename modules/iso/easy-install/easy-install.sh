#!/usr/bin/env bash

set -euxo pipefail

# alternatively use '/iso/flake' to install based of the flake when the iso was created
FLAKE_URL="github:quaoz/flake"

# check for root
if [[ $EUID -ne 0 ]]; then
  exec sudo "$0"
fi

# confirm or die
cod() {
  if [[ -n $1 ]]; then
    gum format --type markdown "$1"
  fi

  if ! gum confirm --default=no "${2:-"Are you sure you want to continue?"}"; then
    exit 0
  fi
}

# say and die
sad() {
  echo -e "$1" >&2
  exit 1
}

cod "# This script _will_ make irrevocable and destructive changes to your system."

# check network connection
if [[ $(nmcli networking connectivity check) != "full" ]]; then
  mode=$(gum choose --header "No network connection. Attempt to configure:" wifi ethernet)

  if [[ $mode == "wifi" ]]; then
    ssid=$(nmcli -g SSID dev wifi | gum choose --header "Select access point")
    pass=$(gum input --password --header "Enter password for $ssid" --placeholder "password")

    nmcli dev wifi con "$ssid" password "$pass" name "installer-con-$ssid"
  elif [[ $mode == "ethernet" ]]; then
    ifname=$(nmcli -g DEVICE dev | gum choose --header "Select interface to use")
    ipaddr=$(gum input --header "Enter host ip address" --placeholder "x.x.x.x")
    ipcidr=$(gum input --header "Enter ip cidr" --value "24")
    gateway=$(gum input --header "Enter gateway" --value "${ipaddr%.*}.1")

    nmcli con add con-name "installer-con-${ifname}" ifname "$ifname" ipv4.addresses "$ipaddr/$ipcidr" ipv4.gateway "$gateway" ipv4.dns "9.9.9.9" ipv4.method "manual" type "ethernet"
    nmcli con up "installer-con-${ifname}"
  fi

  if [[ $(nmcli networking connectivity check) != "full" ]]; then
    sad "failed to establish network connection"
  fi
fi

hostname=$(gum input --header "Enter hostname" --value "$(hostname)")

use_disko=false
if [[ "$(nix eval "$FLAKE_URL#nixosConfigurations.$hostname.config" --apply 'builtins.hasAttr "disko"')" == "true" ]]; then
  if [[ "$(nix eval "$FLAKE_URL#nixosConfigurations.$hostname.config.disko.devices.disk" --apply 'x: x != {}')" == "true" ]]; then
    use_disko=true
  else
    cod "" "$hostname has empty disko configuration. Proceed with manual formatting?"
  fi
fi

default_disks=false
if [[ "$(nix eval "$FLAKE_URL#nixosConfigurations.$hostname.config.garden.hardware.disks.enable")" == "true" ]]; then
  default_disks=true
fi

persist=false
if [[ "$(nix eval "$FLAKE_URL#nixosConfigurations.$hostname.config.garden.persist.enable")" == "true" ]]; then
  persist=true
fi

impermanence=false
if [[ "$(nix eval "$FLAKE_URL#nixosConfigurations.$hostname.config.garden.hardware.disks.impermanence.enable")" == "true" ]]; then
  impermanence=true
fi

# rules:
#   - $default_disks --> $use_disko
#   - ($default_disks && $persist) --> $impermanence
#   - ($default_disks && $impermanence) --> $persist
#
# these are enforced by nix and protect us from some insane/invalid configurations
# we can ignore $impermanence as it only matters when $default_disks is true
# and must have the same value as $persist in that case

# we check for them early anyway to prevent unneeded pain
if [[ $default_disks && (! $use_disko ||
  ($persist && ! $impermanence) ||
  ($impermanence && ! $persist)) ]]; then
  sad "your doing something evil :(\nhint: read this script and try to build $hostname"
fi

# states:
#   - normal      $default_disks && ! $persist
#   - normal-imp: $default_disks && $persist
#   - disko:      $use_disko && ! $default_disks && ! $persist
#   - disko-imp:  $use_disko && ! $default_disks && $persist
#   - custom:     ! $use_disko && ! $persist
#   - custom-imp: ! $use_disko && $persist
#
# we can handle all of these states except custom-imp (well we could but there
# isn't really a good reason to not just use normal-imp), custom is also fairly
# pointless but easier to manage

if $use_disko; then
  # normal || normal imp || disko || disko imp
  eval "$(nix build --no-link --print-out-paths "$FLAKE_URL#nixosConfigurations.$hostname.config.system.build.diskoScript")"
else
  # custom || custom imp
  if $persist; then
    gum format --type markdown <<EOF
You have impermanence enabled but are not using disko, this script does not
support this setup.

You should either:
- use the standard disk configuration with impermanence:
    - enable \`config.garden.hardware.disks.enable\`
    - and \`config.garden.hardware.disks.impermanence.enable\`
- or define a custom disko config
EOF
    exit 0
  fi

  #shellcheck disable=SC2016
  cod '
    You are not using disko however the file system we are about to create is almost
    identical to the result of enabling `config.garden.hardware.disks.enable`.

    It is highly recommended to use this instead or define a custom disko config
    if the standard config does not suit your needs.'

  drive=$(lsblk -nlo PATH | gum choose --header "Select drive to install to")

  # create some partitions
  parted "$drive" -- mklabel gpt
  parted "$drive" -- mkpart boot fat32 1MB 512MB
  parted "$drive" -- mkpart root btrfs 512MB -8GB
  parted "$drive" -- mkpart swap linux-swap -8GB 100%
  parted "$drive" -- set 1 esp on

  # determine partition prefix based on drive type
  if [[ $drive == *"nvme"* ]]; then
    # nvme drives like /dev/nvme0n1p1
    boot_part="${drive}p1"
    root_part="${drive}p2"
    swap_part="${drive}p3"
  else
    # handle /dev/sda1 style drives
    boot_part="${drive}1"
    root_part="${drive}2"
    swap_part="${drive}3"
  fi

  # format the partitions
  mkfs.fat -F32 -n boot "$boot_part"
  mkfs.btrfs -f -L root "$root_part"
  mkswap -L swap "$swap_part"
  swapon "$swap_part"

  # mount the partitions whilst ensuring the directories exist
  mkdir -p /mnt
  mount "$root_part" /mnt
  mkdir -p /mnt/boot
  mount "$boot_part" /mnt/boot
fi

sshdir='/mnt/etc/ssh'
if $persist; then
  state_location="$(nix eval --raw "$FLAKE_URL#nixosConfigurations.$hostname.config.garden.persist.location")"
  sshdir="/mnt${state_location}/etc/ssh"
fi

# create some ssh keys with no passphrases
mkdir -p "$sshdir"
ssh-keygen -t ed25519 -f "$sshdir/ssh_host_ed25519_key" -N "" -C ""

# setup our installer args based off of our configuration
# this is concept is taken from https://github.com/lilyinstarlight/foosteros/blob/0d40c72ac4e81c517a7aa926b2a1fb4389124ff7/installer/default.nix
installArgs=(--no-channel-copy)
if [ "$(nix eval "$FLAKE_URL#nixosConfigurations.$hostname.config.users.mutableUsers")" = "false" ]; then
  installArgs+=(--no-root-password)
fi

gum format --type markdown <<EOF
Before installing you probably want to rekey your secrets and check the hardware configuration.
> pubkey: \`$(cat "$sshdir/ssh_host_ed25519_key.pub")\`

When you are ready to install, run the following command:
EOF
gum format --type code --language sh "nixos-install --flake \"$FLAKE_URL#$hostname\" ${installArgs[*]}"
