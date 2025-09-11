{
  inputs,
  config,
  lib,
  self,
  ...
}: let
  cfg = config.garden.persist;
in {
  # TODO: user impermanence? do we actually want it?
  options.garden.persist = {
    enable = lib.mkEnableOption "persistence";
    location = self.lib.mkOpt (lib.types.pathWith {
      absolute = true;
      inStore = false;
    }) "/persistent" "Where to store state";
  };

  imports = [
    inputs.preservation.nixosModules.default

    # allow using `garden.persist.{dirs,files}` bcos im lazy
    (lib.mkAliasOptionModule ["garden" "persist" "dirs"] ["preservation" "preserveAt" cfg.location "directories"])
    (lib.mkAliasOptionModule ["garden" "persist" "files"] ["preservation" "preserveAt" cfg.location "files"])
  ];

  config = lib.mkIf cfg.enable {
    preservation = {
      enable = true;

      preserveAt."${cfg.location}" = {
        directories = lib.flatten [
          "/root"
          "/var/lib/systemd/coredump"

          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ];

        files = lib.flatten [
          "/etc/adjtime"

          {
            file = "/etc/machine-id";
            inInitrd = true;
            how = "symlink";
            configureParent = true;
          }

          (lib.optionals config.services.openssh.enable (
            builtins.map (key: [
              {
                file = key.path;
                mode = "0600";
                inInitrd = true;
              }
              {
                file = "${key.path}.pub";
                mode = "0644";
                inInitrd = true;
              }
            ])
            config.services.openssh.hostKeys
          ))
        ];
      };
    };

    systemd.services.systemd-machine-id-commit = {
      unitConfig.ConditionPathIsMountPoint = [
        ""
        "/state/etc/machine-id"
      ];
      serviceConfig.ExecStart = [
        ""
        "systemd-machine-id-setup --commit --root /persistent"
      ];
    };
  };
}
