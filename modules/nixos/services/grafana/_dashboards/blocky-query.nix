{pkgs, ...}: let
  postgresDS = {
    current = {};
    includeAll = false;
    label = "Datasource";
    name = "DS_POSTGRES";
    options = [];
    query = "postgres";
    refresh = 1;
    regex = "";
    type = "datasource";
  };
in
  "${pkgs.blocky.src}/docs/blocky-query-grafana-postgres.json"
  |> builtins.readFile
  |> builtins.fromJSON
  |> builtins.mapAttrs (
    n: v:
      if n == "templating"
      then {
        list = v.list ++ [postgresDS];
      }
      else v
  )
  |> builtins.toJSON
  |> builtins.toFile "blocky-query-dash.json"
