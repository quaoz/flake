{
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  inherit (config.age) secrets;
  cfg = config.garden.services.glance-agent;
in {
  options.garden.services.glance-agent = self.lib.mkServiceOpt "glance-agent" {
    inherit (config.garden.profiles.server) enable;
    port = 9200;
    host = "0.0.0.0";
  };

  config = lib.mkIf cfg.enable {
    garden.secrets.normal = {
      glance-agent-token = {
        generator.script = "alnum";
        intermediary = true;
      };

      glance-agent-env-file.generator = self.lib.mkEnvFile {
        TOKEN = secrets.glance-agent-token;
      };
    };

    systemd.services.glance-agent = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      environment = {
        PORT = "${builtins.toString cfg.port}";
        HOSt = cfg.host;
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe pkgs.glance-agent}";
        EnvironmentFile = secrets.glance-agent-env-file.path;
        Restart = "always";
      };
    };
  };
}
