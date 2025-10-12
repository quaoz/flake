{
  lib,
  buildGoModule,
  fetchFromGitLab,
}: let
  pname = "fail2ban-prometheus-exporter";
  version = "0.10.3";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitLab {
      owner = "nekowinston";
      repo = "fail2ban-prometheus-exporter";
      rev = "96185ca763cc39a13520ca66bfe637bea0dad251";
      hash = "sha256-wRbVlFUNQcmG5cNxZV4wpV3V4WqiAbGcSgbAnOGTrhE=";
    };

    vendorHash = "sha256-5N5uTXMRkIARJEqULF0PGi2l2bpeumXUcg9310XoLWU=";

    ldflags = ["-s" "-w"];

    meta = {
      description = "Collect and export metrics on Fail2Ban";
      homepage = "https://gitlab.com/hctrdev/fail2ban-prometheus-exporter.git";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [quaoz];
      mainProgram = "fail2ban-prometheus-exporter";
    };
  }
