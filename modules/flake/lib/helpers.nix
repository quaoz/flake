{lib, ...}: let
  typeDefaults = {
    string = "";
    set = {};
    list = [];
  };

  /**
  like `lib.recursiveUpdate` but throws an error if an attribute will be overwritten

  # Inputs

  `lhs`
  : left attribute set of the merge

  `rhs`
  : right attribute set of the merge

  # Type

  ```nix
  safeRecursiveUpdate :: AttrSet -> AttrSet -> AttrSet
  ```

  # Example

  ```nix
  safeRecursiveUpdate { a = 0; b = { c = 1; d = {}; }; } { e = 2; b = { c = 1; d = { f = 3; }; }; }
  => { a = 0; b = { c = 1; d = { f = 3; }; }; e = 2; }
  ```
  */
  safeRecursiveUpdate = lib.recursiveUpdateUntil (p: lhs: rhs:
    if builtins.typeOf lhs != builtins.typeOf rhs
    then builtins.throw "type mismatch at ${builtins.concatStringsSep "." p}"
    else if builtins.isAttrs lhs
    then false
    else if lhs != rhs
    then builtins.throw "collision at ${builtins.concatStringsSep "." p}"
    else true);

  /**
  merges a list of attribute sets throwing an error if there is a collision

  # Inputs

  `list`
  : list of attribute sets to merge

  # Type

  ```nix
  safeMerge :: [ AttrSet ] -> AttrSet
  ```

  # Example

  ```nix
  safeMerge [ { a = 1; } { b = { c = 1; }; } { b = { d = 1; }; } ]
  => { a = 1; b = { c = 1; d = 1; }; }
  ```
  */
  safeMerge = list: builtins.foldl' safeRecursiveUpdate {} list;

  /**
  get all host configurations

  # Inputs

  `self`
  : the flake self

  `includeDarwin`
  : whether to include darwin configurations (default: false)

  `includeIso`
  : whether to include ISO configurations (default: false)

  # Type

  ```nix
  hosts :: AttrSet -> AttrSet -> AttrSet
  ```

  # Example

  ```nix
  hosts self { includeDarwin = true; }
  => { host1 = ...; host2 = ...; }
  ```
  */
  hosts = self: opts: hostsWhere self (_: _: true) opts;

  /**
  get all hosts matching the predicate function

  # Inputs

  `self`
  : the flake

  `pred`
  : predicate function that takes hostname and host config

  `includeDarwin`
  : whether to include darwin configurations (default: false)

  `includeIso`
  : whether to include ISO configurations (default: false)

  # Type

  ```nix
  hostsWhere :: AttrSet -> (String -> AttrSet -> Bool) -> AttrSet -> AttrSet
  ```

  # Example

  ```nix
  hostsWhere self (hn: hc: lib.hasPrefix "server" hn) { includeDarwin = true; }
  => { server1 = ...; server2 = ...; }
  ```
  */
  hostsWhere = self: pred: {
    includeDarwin ? false,
    includeIso ? false,
  }:
    lib.attrsets.unionOfDisjoint self.nixosConfigurations (
      if includeDarwin
      then self.darwinConfigurations
      else {}
    )
    |> lib.filterAttrs (
      hn: hc:
        (includeIso || !hc.config.garden.profiles.iso.enable)
        && pred hn hc
    );

  /**
  ldTernary, short for linux darwin ternary

  # Inputs

  `pkgs`
  : the package set

  `l`
  : the value to return if the host platform is linux

  `d`
  : the value to return if the host platform is darwin

  # Type

  ```nix
  ldTernary :: AttrSet -> Any -> Any -> Any
  ```

  # Example

  ```nix
  ldTernary pkgs "linux" "darwin"
  => "linux"
  ```
  */
  ldTernary = pkgs: l: d:
    if pkgs.stdenv.hostPlatform.isLinux
    then l
    else if pkgs.stdenv.hostPlatform.isDarwin
    then d
    else throw "Unsupported system: ${pkgs.stdenv.system}";

  /**
  returns the given value if the host platform is darwin

  # Inputs

  `pkgs`
  : the package set

  `as`
  : the value to return

  # Type

  ```nix
  onlyDarwin :: AttrSet -> Any -> Any
  ```

  # Example

  ```nix
  onlyDarwin pkgs "darwin"
  => "darwin"
  ```
  */
  onlyDarwin = pkgs: as:
    if pkgs.stdenv.hostPlatform.isDarwin
    then as
    else typeDefaults."${builtins.typeOf as}" or null;

  /**
  returns the given value if the host platform is linux

  # Inputs

  `pkgs`
  : the package set

  `as`
  : the value to return

  # Type

  ```nix
  onlyLinux :: AttrSet -> Any -> Any
  ```

  # Example

  ```nix
  onlyLinux pkgs "linux"
  => "linux"
  ```
  */
  onlyLinux = pkgs: as:
    if pkgs.stdenv.hostPlatform.isLinux
    then as
    else typeDefaults."${builtins.typeOf as}" or null;

  /**
  determines if a program is enabled in the configuration

  # Inputs

  `config`
  : the configuration

  `program`
  : the program to check

  # Type

  ```nix
  isEnabled :: AttrSet -> String -> Bool
  ```

  # Example

  ```nix
  isEnabled config "bat"
  => true
  ```
  */
  isEnabled = config: program:
    builtins.hasAttr program config.programs && config.programs.${program}.enable;
in {
  inherit ldTernary isEnabled onlyDarwin onlyLinux safeRecursiveUpdate safeMerge hostsWhere hosts;
}
