# things this provides:
#
#  - pkgs: nixpkgs.legacyPackages.<currentSystem>
#  - pwd: $PWD
#  - hostname: $HOSTNAME
#  - self: flake in $PWD
#  - self.<name>.<currentSystem> as <name>'
info: _: prev: let
  inherit (info) currentSystem;

  # same as `lib.optionalAttrs`
  optionalAttrs = predicate: attrs:
    if predicate
    then attrs
    else {};

  # if an attrset has an attribute for the current system expose
  collapse = attrs: old: new:
    optionalAttrs (builtins.hasAttr old attrs && builtins.hasAttr currentSystem attrs.${old} && attrs.${old}.${currentSystem} != {}) {
      ${new} = attrs.${old}.${currentSystem};
    };

  pwd = builtins.getEnv "PWD";
  hostname = builtins.getEnv "HOSTNAME";

  nixpkgs = builtins.getFlake "nixpkgs";

  # if there is a flake in the current directory load it
  self = let
    flakepath = "${pwd}/flake.nix";
  in
    if builtins.pathExists flakepath && builtins.elem (builtins.readFileType flakepath) ["regular" "symlink"]
    then builtins.getFlake pwd
    else {};
in
  (
    builtins.foldl' (a: b: a // b) {} (
      [
        {inherit pwd hostname;}

        # expose self if it exists
        (optionalAttrs (self != {}) {inherit self;})

        # expose packages for current system
        (collapse nixpkgs "legacyPackages" "pkgs")
      ]
      ++ (
        # expose all persystem attrs of the current flake as <name>'
        builtins.attrNames self
        |> builtins.filter (n: builtins.isAttrs self.${n})
        |> builtins.map (n: collapse self n "${n}'")
        |> builtins.filter (x: x != {})
      )
    )
  )
  # we don't want to override any already defined attrs
  // prev
