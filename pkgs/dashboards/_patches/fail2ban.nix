let
  mapPanel = {
    datasource = {
      type = "prometheus";
      uid = "\${DS_PROMETHEUS}";
    };
    fieldConfig = {
      defaults = {
        color = {mode = "thresholds";};
        custom = {
          hideFrom = {
            legend = false;
            tooltip = false;
            viz = false;
          };
        };
        mappings = [];
        thresholds = {
          mode = "absolute";
          steps = [
            {
              color = "green";
              value = null;
            }
            {
              color = "yellow";
              value = 5;
            }
            {
              color = "orange";
              value = 10;
            }
            {
              color = "red";
              value = 20;
            }
          ];
        };
      };
      overrides = [];
    };
    gridPos = {
      h = 20;
      w = 24;
      x = 0;
      y = 27;
    };
    id = 211;
    options = {
      basemap = {
        config = {};
        name = "Layer 0";
        type = "default";
      };
      controls = {
        mouseWheelZoom = true;
        showAttribution = false;
        showDebug = false;
        showMeasure = false;
        showScale = false;
        showZoom = true;
      };
      layers = [
        {
          config = {
            blur = 15;
            radius = 1;
            weight = {
              fixed = 1;
              max = 1;
              min = 0;
            };
          };
          location = {mode = "auto";};
          name = "Banned IPs location";
          tooltip = true;
          type = "heatmap";
        }
      ];
      tooltip = {mode = "details";};
      view = {
        id = "coords";
        lat = 20;
        lon = 0;
        zoom = 2.5;
      };
    };
    pluginVersion = "9.1.8";
    targets = [
      {
        datasource = {
          type = "prometheus";
          uid = "\${DS_PROMETHEUS}";
        };
        editorMode = "code";
        expr = "f2b_banned_per_geo{instance=~\"$instance\"}";
        format = "table";
        legendFormat = "";
        range = true;
        refId = "A";
      }
    ];
    title = "Banned IPs";
    type = "geomap";
  };
in
  n: v:
    if n == "templating"
    then {
      list =
        builtins.map (
          x:
            if x.type == "datasource" && x.query == "prometheus"
            then
              x
              // {
                name = "DS_PROMETHEUS";
              }
            else x
        )
        v.list;
    }
    else if n == "panels"
    then v ++ [mapPanel]
    else v
