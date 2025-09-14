{
  osConfig,
  lib,
  config,
  ...
}: let
  inherit (osConfig.age) secrets;
in {
  config = {
    garden.oneshots.atuin-login = let
      atuin = lib.getExe config.programs.atuin.package;
    in {
      description = "atuin login";
      script = ''
        if ${atuin} status | grep -q "not logged in"; then
          ${atuin} login --username ${osConfig.me.username} --password "$(cat ${secrets.atuin-password.path})" --key "$(cat ${secrets.atuin-key.path})"
        fi
      '';
    };

    programs.atuin = {
      enable = true;

      flags = ["--disable-up-arrow"];
      settings = {
        dialect = "uk";
        show_preview = true;
        inline_height = 30;
        style = "compact";
        sync_address = "https://atuin.internal.${osConfig.garden.domain}";
        sync_frequency = "5m";
        update_check = false;
      };
    };
  };
}
