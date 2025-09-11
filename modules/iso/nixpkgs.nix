{config, ...}: {
  imports = [
    ../common/nixpkgs.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      nixVersions =
        prev.nixVersion
        // {
          stable = config.nix.package;
        };

      inherit
        (final.lixPackageSets.latest)
        nixpkgs-review
        nix-direnv
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];
}
