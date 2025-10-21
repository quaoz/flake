let
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
  n: v:
    if n == "templating"
    then {
      list = v.list ++ [postgresDS];
    }
    else v
