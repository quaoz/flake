{
  lib,
  self,
  config,
  ...
}: let
  inherit (config.age) secrets;
  cfg = config.garden.services.remote-builder;

  # TODO: move this and build signing key (modules/common/nix:extra-trusted-public-keys) somewhere
  builder-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDQkxMTmEl67/weuxI1vn+WWGNfEV81v3bPMGm9C/sWo";
in {
  options.garden.services.remote-builder = self.lib.mkServiceOpt "remote-builder" {
    enable = config.garden.profiles.server.enable && !config.garden.profiles.slow.enable;
    user = "nix-remote";
    group = "nix-remote";
  };

  config = lib.mkIf cfg.enable {
    garden.secrets.other = [
      {
        path = "services/remote-builder/password.age";
        inherit (cfg) user group;
      }
    ];

    users.users.${cfg.user} = {
      inherit (cfg) group;
      createHome = true;
      isNormalUser = true;

      hashedPasswordFile = secrets.remote-builder-password.path;
      openssh.authorizedKeys.keys = [builder-key];
    };

    users.groups.${cfg.group} = {};

    nix.settings.trusted-users = [cfg.user];
  };
}
