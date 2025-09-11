{config, ...}: let
  inherit (config.me) username;
  inherit (config.age) secrets;

  ifGroupsExist = builtins.filter (g: builtins.hasAttr g config.users.groups);
in {
  config = {
    garden.secrets.user = ["password.age"];

    users = {
      mutableUsers = false;

      users = {
        root = {
          hashedPasswordFile = secrets.password.path;
        };

        ${username} = {
          name = username;
          uid = 1000;

          home = "/home/${username}";
          shell = "/run/current-system/sw/bin/bash";

          isNormalUser = true;
          isSystemUser = false;

          hashedPasswordFile = secrets.password.path;

          extraGroups =
            [
              "wheel"
            ]
            ++ ifGroupsExist [
              "networkmanager"
            ];
        };
      };
    };
  };
}
