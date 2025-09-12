{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
}: let
  pname = "launchctl-completion";
  version = "1.0";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "CamJN";
      repo = "launchctl-completion";
      rev = "3cb60f81a1c588273eababbf6e627e041013844d";
      hash = "sha256-wtZhrDWWjEc1rdL3Mf/b582dklialIcWa3gwqyHc3J4=";
    };

    nativeBuildInputs = [installShellFiles];

    installPhase = ''
      installShellCompletion --bash launchctl-completion.sh
    '';

    meta = {
      description = "i hate launchctl so so so much";
      homepage = "https://github.com/CamJN/launchctl-completion";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
      maintainers = with lib.maintainers; [ivankovnatsky];
      mainProgram = pname;
    };
  }
