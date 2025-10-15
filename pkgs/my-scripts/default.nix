{
  lib,
  stdenv,
  bash,
  ...
}: let
  name = "my-scripts";
  src = ./scripts;
in
  stdenv.mkDerivation {
    inherit name src;

    postPatch = ''
      substituteInPlace *.sh --replace-fail "#!/usr/bin/env bash" "#!${lib.getExe bash}"
    '';

    installPhase = ''
      mkdir -p $out/bin

      for script in *.sh; do
        name="''${script%.*}"
        mv "$script" "$out/bin/$name"
      done
    '';

    meta = {
      description = "miscellaneous scripts";
      maintainers = with lib.maintainers; [quaoz];
      platforms = lib.platforms.all;
    };
  }
