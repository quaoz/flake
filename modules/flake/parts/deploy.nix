{
  inputs,
  config,
  self,
  lib,
  ...
}: let
  inherit (import ../lib/helpers.nix {inherit lib;}) hosts;
in {
  # TODO: darwin deployment?
  # configure flake deployment
  flake = {
    deploy = {
      user = "root";
      sshUser = config.me.username;
      sshOpts = ["-A"];

      nodes =
        hosts self {}
        |> builtins.mapAttrs (hostname: hostconfig: let
          inherit (hostconfig.pkgs.stdenv.hostPlatform) system;
        in {
          inherit hostname;

          # don't build on slow hosts
          remoteBuild = !hostconfig.config.garden.profiles.slow.enable;

          profiles.system.path = inputs.deploy-rs.lib.${system}.activate.${hostconfig.class} hostconfig;
        });
    };

    checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };
}
