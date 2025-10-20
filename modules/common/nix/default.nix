{
  self,
  pkgs,
  inputs,
  lib,
  ...
}: {
  config.nix = let
    flakeInputs = lib.filterAttrs (n: v: lib.types.isType "flake" v && n != "self") inputs;
  in {
    # disable nix channels
    channel.enable = false;

    # pin registry to avoid unnecessary downloads
    registry =
      (lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs)
      // {
        nixpkgs = lib.mkForce {flake = inputs.nixpkgs;};
      };

    # specify nix path
    nixPath =
      lib.mapAttrsToList (
        k: v: "${k}=${self.lib.onlyLinux pkgs "flake:"}${v.outPath}"
      )
      flakeInputs;

    # automatic gc
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };

    # https://docs.lix.systems/manual/lix/nightly/command-ref/conf-file.html#available-settings
    settings = let
      trusted = self.lib.ldTernary pkgs ["@wheel"] ["@admin"];
    in
      {
        # don't automatically accept nix config from flakes
        accept-flake-config = false;

        # users allowed to interact with nix daemon
        allowed-users = trusted;
        # users allowed to manage the nix store
        trusted-users = trusted;

        # automatically pick UIDs for builds (depends: auto-allocate-uids)
        auto-allocate-uids = pkgs.stdenv.isLinux;

        # let nix replace duplicate store files with links
        # broken on darwin but fixed by lix
        auto-optimise-store = true;

        # let remote builders use their own binary substitutes
        builders-use-substitutes = true;

        # max number of parallel connections to use
        http-connections = 50;

        # don't stop building if a build fails
        keep-going = true;

        # show more lines when a build fails
        log-lines = 35;

        # automatically decide the max number of jobs
        max-jobs = "auto";

        # free up to 20GiB when under 5GiB left
        max-free = 20 * 1024 * 1024 * 1024;
        min-free = 5 * 1024 * 1024 * 1024;

        # automatically load flake in current directory and do some other things, see file for details
        repl-overlays = [
          ./repl-overlay.nix
        ];

        # use sandbox on linux
        sandbox = pkgs.stdenv.isLinux;

        # use xdg directories for nix stuff
        use-xdg-base-directories = true;

        # don't warn about dirty git tree
        warn-dirty = false;

        # https://docs.lix.systems/manual/lix/nightly/contributing/experimental-features.html
        # https://git.lix.systems/lix-project/lix/src/branch/main/lix/libutil/experimental-features
        experimental-features = [
          # lets nix automatically pick UIDs for builds instead of creating nixbld accounts
          "auto-allocate-uids"

          # lets nix execute builds inside cgroups
          "cgroups"

          # coerce integers into strings
          # "coerce-integers"

          # enable fetch-closure builtin
          "fetch-closure"

          # enable flakes
          "flakes"

          # lets lix invoke custom commands through its main binary
          "lix-custom-sub-commands"

          # enable nix command
          "nix-command"

          # enable nix pipe operator
          "pipe-operator"
        ];
      }
      // self.lib.onlyLinux pkgs {
        # use cgroups on linux (depends: cgroups)
        use-cgroups = true;
      };
  };
}
