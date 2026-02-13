{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf osConfig.garden.profiles.desktop.enable {
    services.yubikey-agent = {
      enable = true;

      # WATCH: https://github.com/FiloSottile/yubikey-agent/issues/153
      #      - https://github.com/FiloSottile/yubikey-agent/pull/155
      package = pkgs.yubikey-agent.overrideAttrs (_final: _prev: {
        src = pkgs.fetchFromGitHub {
          owner = "e-nomem";
          repo = "yubikey-agent";
          rev = "add-ed25519-keys";
          hash = "sha256-LQ2Go/pJgHW2W3bnOD8LcLf8JW93sI70W05FVoTFxco=";
        };

        vendorHash = "sha256-w5H6thqDZINcic6jJz6dcGL3+LkR2Iz0UFxwI/vkQsc=";
      });
    };
  };
}
