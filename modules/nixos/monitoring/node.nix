{
  config,
  lib,
  self,
  ...
}: let
  cfg = config.garden.profiles.monitoring.node;
in {
  options.garden.profiles.monitoring.node = self.lib.mkMonitorOpt "node" {
    inherit (config.garden.profiles.monitoring) enable;
    port = 9001;
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters = {
      node = {
        inherit (cfg) enable port;

        enabledCollectors = [
          "logind"
          "systemd"
          "processes"
        ];
      };
    };
  };
}
