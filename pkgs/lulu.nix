{
  makeWrapper,
  undmg,
  lib,
  fetchurl,
  stdenv,
  ...
}: let
  appName = "LuLu";
  pname = lib.toLower appName;
  version = "3.1.5";

  src = fetchurl {
    url = "https://github.com/objective-see/LuLu/releases/download/v${version}/LuLu_${version}.dmg";
    sha256 = "sha256-eFrOZv6KSZlmLtyPORrD2Low/e7m7HU1WeuT/w8Us7I=";
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
      description = "LuLu is the free open-source macOS firewall";
      homepage = "https://github.com/objective-see/LuLu";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [quaoz];
      platforms = platforms.darwin;
      sourceProvenance = [sourceTypes.binaryNativeCode];
      mainProgram = pname;
    };
  }
