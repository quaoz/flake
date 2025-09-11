{lib, ...}: let
  helpers = import ./helpers.nix {inherit lib;};

  /**
  recursively list all nix files in a directory, excludes paths beginning with
  an underscore

  if given a file instead of a directory it will return a list of nix files in
  the same directory as the file excluding the file

  # Inputs

  `p`
  : the path to list

  # Type

  ```nix
  nixFiles :: Path --> [ Path ]
  ```

  # Example

  ```nix
  nixFiles ./.
  => [ ./flake.nix ./nix/other.nix ]
  ```
  */
  nixFiles = p: nixFiles' p [];

  /**
  recursively list all nix files in a directory, excludes specified paths and
  paths beginning with an underscore

  if given a file instead of a directory it will return a list of nix files in
  the same directory as the file excluding the file

  # Inputs

  `p`
  : the path to list

  # Type

  ```nix
  nixFiles :: Path --> [ Path ] --> [ Path ]
  ```

  # Example

  ```nix
  nixFiles' ./. [ ./nix/other.nix ]
  => [ ./flake.nix ]
  ```
  */
  nixFiles' = p: excludes: let
    f = dir: excludes:
      builtins.readDir dir
      |> lib.filterAttrs (
        n: _: !lib.hasPrefix "_" n && !builtins.elem (dir + "/${n}") excludes
      )
      |> lib.mapAttrsToList (
        n: type:
          if type == "directory"
          then f (dir + "/${n}") excludes
          else dir + "/${n}"
      )
      |> lib.flatten
      |> builtins.filter (f: lib.hasSuffix ".nix" f);
  in
    if builtins.readFileType p == "directory"
    then f p excludes
    else f (builtins.dirOf p) ([p] ++ excludes);

  /**
  imports a nix file automatically providing the necessary inputs

  # Inputs

  `inputs`
  : the inputs to be made available to the file

  `path`
  : the file to import

  # Type

  ```nix
  autoImport :: Path --> AttrSet
  ```

  # Example

  ```nix
  autoImport ./default.nix
  => {...}
  ```
  */
  autoImport = inputs: path: let
    f = lib.toFunction (import path);
  in
    f
    |> lib.functionArgs
    |> builtins.mapAttrs (n: _: inputs.${n})
    |> f;

  /**
  recursively imports and merges all nix files in a directory

  # Inputs

  `inputs`
  : the inputs to be made available to the files

  `dir`
  : the directory to import

  # Type

  ```nix
  harvest :: Path --> AttrSet
  ```

  # Example

  ```nix
  harvest ./.
  => {...}
  ```
  */
  harvest = inputs: dir:
    nixFiles dir
    |> builtins.map (autoImport inputs)
    |> helpers.safeMerge;
in {
  inherit nixFiles nixFiles' autoImport harvest;
}
