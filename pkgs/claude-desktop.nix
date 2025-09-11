{
  makeWrapper,
  unzip,
  lib,
  fetchurl,
  stdenv,
  ...
}: let
  appName = "Claude";
  pname = lib.toLower appName;
  version = "0.12.55";

  src = fetchurl {
    url = "https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest/release-${version}-artifact-d55c63cae429e48c72cd9f306dbf2880a694e8fe.zip";
    sha256 = "sha256-L+fGBO6oNBkUlO6fKhPHmY6t5XpBKLNUL0yas+JTvmk=";
  };
in
  stdenv.mkDerivation {
    inherit src pname version;

    sourceRoot = ".";
    nativeBuildInputs = [makeWrapper unzip];

    installPhase = ''
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
      makeWrapper $out/Applications/${appName}.app/Contents/MacOS/${appName} $out/bin/${pname}
    '';

    meta = with lib; {
      description = "Claude Desktop";
      homepage = "https://claude.ai/download";
      license = licenses.unfree;
      maintainers = with maintainers; [quaoz];
      platforms = platforms.darwin;
      sourceProvenance = [sourceTypes.binaryNativeCode];
      mainProgram = pname;
    };
  }
