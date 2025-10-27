{
  lib,
  buildGoModule,
  fetchFromGitHub,
}: let
  pname = "glance-agent";
  version = "0.1.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "glanceapp";
      repo = "agent";
      rev = "v${version}";
      hash = "sha256-eNhOelHR3EB3RWWMe7fG6vklgADX7XFy6QMI4Lfr8oM=";
    };

    vendorHash = "sha256-vjcyZctfgnAhzFEF0c+GhtWQqa4gVvLLj0E3sCLS0RE=";

    ldflags = [
      "-s"
      "-w"
      "-X=github.com/glanceapp/agent/internal/agent.buildVersion=v${version}"
    ];

    meta = with lib; {
      description = "System metrics service for glance";
      homepage = "https://github.com/glanceapp/agent.git";
      license = lib.licenses.gpl3Only;
      maintainers = with maintainers; [quaoz];
      platforms = platforms.unix;
      mainProgram = "agent";
    };
  }
