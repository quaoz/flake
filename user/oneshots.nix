{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  options.garden.oneshots = self.lib.mkOpt (lib.types.attrsOf lib.types.package) {} "Simple scripts to run at user login";

  config = {
    systemd.user.services = lib.mkIf pkgs.stdenv.isLinux (
      builtins.mapAttrs (_: script: {
        Unit = {
          Description = script.meta.description;
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${lib.getExe script}";
        };
        Install.WantedBy = ["default.target"];
      })
      config.garden.oneshots
    );

    launchd.agents = lib.mkIf pkgs.stdenv.isDarwin (
      builtins.mapAttrs (name: script: {
        enable = true;
        config = {
          ServiceDescription = script.meta.description;
          ProgramArguments = ["${lib.getExe script}"];
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };
          ProcessType = "Background";
          RunAtLoad = true;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${name}/stdout";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${name}/stderr";
        };
      })
      config.garden.oneshots
    );
  };
}
