#!/usr/bin/env bash

ARGS='
arg PACKAGE "the package to evaluate"
opt SYSTEM "the system to evaluate the package for" -s --system
opt STORE "query a store for the package, returns the hash or nothing if package missing" --store
flag ONLY_HASH "only print the package hash" -h --hash
'

# shellcheck disable=SC1091
source args "lix-where" "$ARGS" --description 'display the store path of a package' --no-short-help --export-panic -- "$@"

if [[ -z $PACKAGE ]]; then
  panic 'no package specified'
fi

# shellcheck disable=SC2016
cs='${builtins.currentSystem}'
expr="
let
  nixpkgs = builtins.getFlake \"nixpkgs\";
  pkgs = nixpkgs.legacyPackages.${SYSTEM:-$cs};
in
  pkgs.${PACKAGE}.outPath
"
path="$(nix eval --quiet --impure --raw --expr "$expr" 2>/dev/null)"

if [[ -z $path ]]; then
  panic "could not find '$PACKAGE' ${SYSTEM:+for $SYSTEM}"
fi

if [[ $ONLY_HASH == true || -n $STORE ]]; then
  hash="${path##*/}" # remove store path
  hash="${hash%%-*}" # remove name (+version)

  if [[ -n $STORE && ! $(nix store --quiet --store "$STORE" path-from-hash-part "$hash" 2>/dev/null) ]]; then
    exit 0
  fi
fi

if [[ $ONLY_HASH == true ]]; then
  echo "$hash"
else
  echo "$path"
fi
