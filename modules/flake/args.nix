{inputs, ...}: {
  systems = import inputs.systems;

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
