{
  config,
  pkgs,
  self,
  lib,
  ...
}: let
  name = builtins.concatStringsSep "-" [
    config.networking.hostName
    config.system.nixos.release
    config.system.configurationRevision
    pkgs.stdenv.hostPlatform.uname.processor
  ];
in {
  image = {
    baseName = lib.mkImageMediaOverride name;
    extension = "iso";
  };

  isoImage = {
    # volumeID is used is used by stage 1 of the boot process, so it must be distintctive
    volumeID = lib.mkImageMediaOverride name;

    # remove "-installer" boot menu label
    appendToMenuLabel = "";

    contents = [
      {
        # incase i mess up
        source = pkgs.memtest86plus + "/memtest.bin";
        target = "/boot/memtest.bin";
      }
      {
        # make the flake available
        source = lib.cleanSource self;
        target = "/flake";
      }
    ];
  };
}
