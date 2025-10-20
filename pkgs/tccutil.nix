{
  lib,
  fetchFromGitHub,
  python3Packages,
}: let
  pname = "tccutil";
  version = "1.5.0";
in
  python3Packages.buildPythonApplication {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jacobsalmela";
      repo = "tccutil";
      rev = "63f2802a0a06cfcc4b4c3eba7e2041527bb88151";
      hash = "sha256-HeYce8lBVL5zrEcPiKcCwwkGbxR1P/l3dDNB0GcoWjQ=";
    };

    pyproject = false;
    propagatedBuildInputs = with python3Packages; [
      packaging
    ];

    installPhase = ''
      install -Dm755 tccutil.py $out/bin/${pname}
    '';

    meta = with lib; {
      description = "Command line tool to modify OS X's accessibility database";
      homepage = "https://github.com/jacobsalmela/tccutil";
      license = licenses.gpl2Only;
      maintainers = with maintainers; [quaoz];
      platforms = platforms.darwin;
      mainProgram = pname;
    };
  }
