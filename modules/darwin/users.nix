{config, ...}: let
  inherit (config.me) username;
in {
  config.users.users.${username} = {
    name = username;
    uid = 501;

    home = "/Users/${username}";
    shell = "/run/current-system/sw/bin/bash";
  };
}
