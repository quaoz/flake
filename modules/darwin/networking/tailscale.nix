{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.services.tailscale) package;

  authKeyFile = config.age.secrets.tailscale-authkey.path;
in {
  garden.secrets.root = ["services/tailscale/authkey.age"];

  services.tailscale = {
    enable = true;
    overrideLocalDns = true;
  };

  environment.etc = {
    "resolver/ts.net".enable = lib.mkForce false;
    
    # ensuer magic dns always works
    "resolver/internal.${config.garden.domain}".text = "nameserver 100.100.100.100";
    
    # add fallback nameserver for headscale
    "resolver/hs.${config.garden.domain}".text = ''
      nameserver 100.100.100.100
      nameserver 1.1.1.1
    '';
  };

  # automatically authorise machine
  # https://github.com/NixOS/nixpkgs/blob/33e1f9420067659c188dc8a34b8ec2110d28f8c0/nixos/modules/services/networking/tailscale.nix#L172-L200
  launchd.daemons.tailscaled-autoconnect = {
    serviceConfig = {
      Label = "com.tailscale.tailscaled-autoconnect";
      RunAtLoad = true;
    };

    # TODO: can't access `garden.services.headscale.domain`, is there a better way to do this?
    script = let
      statusCommand = "${lib.getExe package} status --json --peers=false | ${lib.getExe pkgs.jq} -r '.BackendState'";
    in ''
      while [[ "$(${statusCommand})" == "NoState" ]]; do
        sleep 0.5
      done

      status=$(${statusCommand})

      if [[ "$status" == "NeedsLogin" || "$status" == "NeedsMachineAuth" ]]; then
        ${lib.getExe package} up --reset --login-server=https://hs.${config.garden.domain} --auth-key=file:${authKeyFile}
      fi
    '';
  };
}
