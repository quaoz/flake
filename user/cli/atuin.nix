{
  osConfig,
  config,
  pkgs,
  ...
}: let
  inherit (osConfig.age) secrets;
in {
  config = {
    garden.oneshots.atuin-login = pkgs.writeShellApplication {
      name = "atuin-login";
      meta.description = "atuin login service";

      runtimeInputs = [
        config.programs.atuin.package
        pkgs.uutils-coreutils-noprefix
        pkgs.ripgrep
      ];

      text = ''
        if atuin status 2>&1 | rg --fixed-strings 'not logged in' --quiet; then
            atuin login                                            \
                --username ${osConfig.me.username}                 \
                --password "$(cat ${secrets.atuin-password.path})" \
                --key "$(cat ${secrets.atuin-key.path})"
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
