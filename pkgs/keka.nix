{
  makeWrapper,
  unzip,
  lib,
  fetchurl,
  stdenv,
  ...
}: let
  appName = "Keka";
  pname = lib.toLower appName;
  version = "1.5.2";

  src = fetchurl {
    url = "https://github.com/aonez/Keka/releases/download/v${version}/Keka-${version}.zip";
    sha256 = "sha256-ZsWfS9OXu82j9EpQVoQXHXeqPBufNq3Z2znp0TirMbc=";
  };
in
  stdenv.mkDerivation {
    inherit src pname version;

    sourceRoot = ".";
    nativeBuildInputs = [makeWrapper unzip];

    installPhase = ''
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
      makeWrapper $out/Applications/${appName}.app/Contents/MacOS/${appName} $out/bin/${pname} --add-flags "--cli"
    '';

    meta = with lib; {
      description = "macOS file archiver";
      homepage = "https://www.keka.io";
      license = licenses.unfree;
      maintainers = with maintainers; [quaoz];
      platforms = platforms.darwin;
      sourceProvenance = [sourceTypes.binaryNativeCode];
      mainProgram = pname;
    };
  }
