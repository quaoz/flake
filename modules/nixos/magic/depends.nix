{
  self,
  lib,
  config,
  ...
}: let
  cfg = config.garden.magic.depends;

  enabledServices =
    self.lib.hosts self {includeDarwin = true;}
    |> builtins.mapAttrs (
      _: hc:
        hc.config.garden.services
        |> lib.filterAttrs (_: sc: sc.enable)
        |> builtins.attrNames
    );
in {
  options.garden.magic.depends = {
    enable = lib.mkEnableOption "service dependency checking" // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    assertions =
      lib.mapAttrsToList (
        sn: sc:
          builtins.concatLists [
            (
              builtins.map (depName: {
                assertion = sc.enable -> builtins.elem depName enabledServices.${config.networking.hostName};
                message = "`${sn}` depends on `${depName}`, enable `garden.services.${depName}` on `${config.networking.hostName}`";
              })
              sc.depends.local
            )
            (
              builtins.map (depName: {
                assertion = sc.enable -> builtins.any (host: builtins.elem depName enabledServices.${host}) (builtins.attrNames enabledServices);
                message = "`${sn}` depends on `${depName}`, enable `garden.services.${depName}` on any host";
              })
              sc.depends.anywhere
            )
            (
              builtins.map (depName: {
                assertion = config.garden.services.${depName}.proxy.visibility != "local";
                message = ''
                  `${depName}` is a local service, however `garden.services.${sn}.depends.anywhere`
                  contains `${depName}`. Local services should not be accessed from other hosts.

                  You probably want to specify it as a local dependency instead.
                '';
              })
              sc.depends.anywhere
            )
          ]
      )
      config.garden.services
      |> builtins.concatLists;
  };
}
