{pkgs, ...}: let
  node-dash = pkgs.fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    rev = "0ea0f0652e41f73bd41b82769baa32912184152b";
    hash = "sha256-FIOeom1pAuBjD/o3ScEe/QZn/Z8R7eADYXTDZIqlmnM=";
  };
in "${node-dash}/prometheus/node-exporter-full.json"
