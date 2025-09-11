let
  /**
  wraps an existing package with additional command-line flags

  # Inputs

  `pkgs`
  : the package set

  `name`
  : the name of the package to wrap

  `flags`
  : additional command-line flags to add to the program

  # Type

  ```nix
  addFlags :: AttrSet -> String -> String -> Derivation
  ```

  # Example

  ```nix
  addFlags pkgs "git" "--no-pager"
  => <derivation git-wrapped>
  ```
  */
  addFlags = pkgs: name: flags: let
    package = pkgs.${name};
  in
    pkgs.symlinkJoin {
      inherit (package) name meta;
      paths = [package];

      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/${package.meta.mainProgram or package.name} --add-flags "${flags}"
      '';
    };
in {
  inherit addFlags;
}
