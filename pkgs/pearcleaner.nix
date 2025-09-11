{
  makeWrapper,
  undmg,
  lib,
  fetchurl,
  stdenv,
  ...
}: let
  appName = "Pearcleaner";
  pname = lib.toLower appName;
  version = "4.5.3";

  src = fetchurl {
    url = "https://github.com/alienator88/Pearcleaner/releases/download/${version}/Pearcleaner.dmg";
    sha256 = "sha256-NHDsszZ3TCiVqPzBohx/BpEpoXc7BC6Q+nN8+sZtzgo=";
  };
in
  stdenv.mkDerivation {
    inherit src pname version;

    sourceRoot = ".";
    nativeBuildInputs = [makeWrapper undmg];

    installPhase = ''
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
      makeWrapper $out/Applications/${appName}.app/Contents/MacOS/${appName} $out/bin/${pname}
    '';

    meta = with lib; {
      description = "An opensource mac app cleaner";
      homepage = "https://itsalin.com/appInfo/?id=pearcleaner";
      license = licenses.asl20;
      maintainers = with maintainers; [quaoz];
      platforms = platforms.darwin;
      sourceProvenance = [sourceTypes.binaryNativeCode];
      mainProgram = pname;
    };
  }
