{
  lib,
  fetchFromGitHub,
  python3Packages,
}: let
  pname = "tccutil";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "jacobsalmela";
    repo = "tccutil";
    rev = "63f2802a0a06cfcc4b4c3eba7e2041527bb88151";
    hash = "sha256-HeYce8lBVL5zrEcPiKcCwwkGbxR1P/l3dDNB0GcoWjQ=";
  };
in
  python3Packages.buildPythonApplication {
    inherit src pname version;

    pyproject = false;
    propagatedBuildInputs = with python3Packages; [
      packaging
    ];

    installPhase = ''
      install -Dm755 tccutil.py $out/bin/${pname}
    '';

    meta = {
      description = "Command line tool to modify OS X's accessibility database";
      homepage = "https://github.com/jacobsalmela/tccutil";
      license = lib.licenses.gpl2Only;
      maintainers = with lib.maintainers; [quaoz];
      platforms = lib.platforms.darwin;
      mainProgram = pname;
    };
  }
