{inputs, ...}: {
  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];

  perSystem = {system, ...}: {
    # controls how packages in the flake are built, not builders in the lib
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };

      overlays = [];
    };
  };
}
