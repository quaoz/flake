{lib, ...}: {
  imports = [
    ../nixos/boot/generic.nix
  ];

  boot = {
    kernelParams = [
      # show diagnostic messages
      "noquiet"

      # load image to ram
      "toram"
    ];

    # WATCH: https://github.com/NixOS/nixpkgs/issues/58959
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "vfat"
    ];
  };
}
