{
  lib,
  stdenv,
  blocky,
  fetchFromGitHub,
  fetchFromGitLab,
  ...
}: let
  name = "dashboards";

  node = fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    rev = "0ea0f0652e41f73bd41b82769baa32912184152b";
    hash = "sha256-FIOeom1pAuBjD/o3ScEe/QZn/Z8R7eADYXTDZIqlmnM=";
  };

  fail2ban = fetchFromGitLab {
    owner = "nekowinston";
    repo = "fail2ban-prometheus-exporter";
    rev = "96185ca763cc39a13520ca66bfe637bea0dad251";
    hash = "sha256-wRbVlFUNQcmG5cNxZV4wpV3V4WqiAbGcSgbAnOGTrhE=";
  };

  srcs = {
    fail2ban = "${fail2ban}/_examples/grafana/dashboard.json";
    blocky-query = "${blocky.src}/docs/blocky-query-grafana-postgres.json";
    blocky = "${blocky.src}/docs/blocky-grafana.json";
    node = "${node}/prometheus/node-exporter-full.json";
  };

  patched =
    builtins.mapAttrs (
      n: v:
        if builtins.pathExists ./_patches/${n}.nix
        then
          builtins.readFile v
          |> builtins.fromJSON
          |> builtins.mapAttrs (import ./_patches/${n}.nix)
          |> builtins.toJSON
          |> builtins.toFile "${n}.json"
        else v
    )
    srcs;
in
  stdenv.mkDerivation {
    inherit name;

    dontUnpack = true;
    dontBuild = true;

    installPhase =
      builtins.foldl' (a: b: a + "\n" + b)
      "mkdir -p $out/share"
      (lib.mapAttrsToList (n: v: "cp ${v} $out/share/${n}.json") patched);

    meta = {
      description = "grafana dashboards";
      maintainers = with lib.maintainers; [quaoz];
      platforms = lib.platforms.all;
    };
  }
