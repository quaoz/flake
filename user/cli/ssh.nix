{
  osConfig,
  self,
  ...
}: let
  inherit (osConfig.age) secrets;
  inherit (osConfig.me) username;

  hosts =
    self.lib.hostsWhere self (_: v: v.config.services.openssh.enable) {includeDarwin = true;}
    |> builtins.attrNames
    |> builtins.concatStringsSep ",";

  remoteBuilders =
    osConfig.nix.buildMachines
    |> builtins.map (x: x.hostName)
    |> builtins.concatStringsSep ",";
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [secrets.ssh-uni-conf.path];

    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent =
          if osConfig.garden.profiles.desktop.enable
          then "yes"
          else "no";

        compression = true;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;

        hashKnownHosts = true;
        userKnownHostsFile = "~/.ssh/known_hosts";

        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      github = {
        user = "git";
        hostname = "github.com";
        identityFile = secrets.ssh-github.path;
      };

      nix-remote = {
        match = "user nix-remote host \"${remoteBuilders}\"";
        identityFile = secrets.ssh-nix-remote-builder.path;
      };

      my-hosts = {
        match = "user ${username} host \"${hosts}\"";
        forwardAgent = true;
      };
    };
  };
}
