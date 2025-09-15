{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}: let
  inherit (config.home) homeDirectory;
in {
  # password manager
  home = lib.mkIf osConfig.garden.profiles.desktop.enable {
    packages = with pkgs; [
      bitwarden-desktop
      # WATCH: https://github.com/NixOS/nixpkgs/issues/339576
      # bitwarden-cli
    ];

    sessionVariables = {
      # TODO: don't really like using ssh-agent, only really need it for deploy-rs
      #       maybe figure out something else or just remove password requirement
      #       for wheel
      # use bitwarden ssh-agent
      SSH_AUTH_SOCK = "${homeDirectory}/.bitwarden-ssh-agent.sock";
    };
  };
}
