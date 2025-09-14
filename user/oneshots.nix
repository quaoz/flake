{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  oneshotType = lib.types.submodule {
    options = {
      description = self.lib.mkOpt' lib.types.str "The script description";
      script = self.lib.mkOpt' lib.types.str "The script to run";
    };
  };
in {
  options.garden.oneshots = self.lib.mkOpt (lib.types.attrsOf oneshotType) {} "Simple scripts to run at user login";

  config = {
    systemd.user.services = lib.mkIf pkgs.stdenv.isLinux (
      builtins.mapAttrs (name: oneshot: let
        script = pkgs.writeShellScript name oneshot.script;
      in {
        Unit = {
          Description = oneshot.description;
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${script}";
        };
        Install.WantedBy = ["default.target"];
      })
      config.garden.oneshots
    );

    launchd.agents = lib.mkIf pkgs.stdenv.isDarwin (
      builtins.mapAttrs (name: oneshot: let
        script = pkgs.writeShellScript name oneshot.script;
      in {
        enable = true;
        config = {
          ServiceDescription = oneshot.description;
          ProgramArguments = ["${script}"];
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
