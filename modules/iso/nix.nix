{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../common/nix/substituters.nix
  ];

  nix = {
    # use cached nix to speed up build
    package = lib.mkForce pkgs.lixPackageSets.latest.lix;

    # disable nix channels
    channel.enable = false;

    # https://docs.lix.systems/manual/lix/nightly/command-ref/conf-file.html#available-settings
    settings = {
      # don't automatically accept nix config from flakes
      accept-flake-config = false;

      # not needed in installer
      auto-optimise-store = false;

      # max number of parallel connections to use
      http-connections = 50;

      # don't stop building if a build fails
      keep-going = true;

      # show more lines when a build fails
      log-lines = 50;

      # automatically decide the max number of jobs
      max-jobs = "auto";

      # don't warn about dirty git tree
      warn-dirty = false;

      # https://docs.lix.systems/manual/lix/nightly/contributing/experimental-features.html
      experimental-features = [
        # enable flakes
        "flakes"

        # enable nix command
        "nix-command"

        # enable nix pipe operator
        "pipe-operator"
      ];
    };
  };
}
