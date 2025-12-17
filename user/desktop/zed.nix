{
  pkgs,
  config,
  lib,
  osConfig,
  ...
}: let
  zed-exe = lib.getExe config.programs.zed-editor.package;
in {
  config = lib.mkIf osConfig.garden.profiles.desktop.enable {
    programs.zed-editor = {
      enable = true;

      extensions = [
        # keep-sorted start
        "basher"
        "git-firefly"
        "haskell"
        "html"
        "just"
        "log"
        "make"
        "nix"
        "scss"
        "toml"
        "wakatime"
        # keep-sorted end
      ];

      userKeymaps = [
        {
          context = "Workspace";
          bindings = {
            "shift shift" = "file_finder::Toggle";
          };
        }
        {
          # Save on entering vim normal mode, should be mapped to workspace::Save and
          # vim::NormalBefore but this can't be done at the moment (cmd-s and ctrl-c
          # map to these two actions respectively).
          #
          # WATCH: https://github.com/zed-industries/zed/issues/7274
          context = "Editor && vim_mode == insert && !menu";
          bindings = {
            escape = [
              "workspace::SendKeystrokes"
              "cmd-s ctrl-c"
            ];
          };
        }
      ];

      # https://zed.dev/docs/configuring-zed
      userSettings = {
        # save when switching tab
        autosave = "on_focus_change";

        # don't try and update
        auto_update = false;

        buffer_font_size = lib.mkForce 14;
        ui_font_size = lib.mkForce 14;

        edit_predictions = {
          mode = "subtle";
        };

        languages = {
          Nix = {
            language_servers = [
              "nil"
              "!nixd"
            ];

            formatter = {
              external = {
                command = "${lib.getExe pkgs.alejandra}";
                arguments = ["--quiet"];
              };
            };
          };

          Python = {
            language_servers = [
              "ty"
              "!basedpyright"
            ];
          };
        };

        lsp = {
          nil = {
            # https://github.com/oxalica/nil/blob/main/docs/configuration.md
            initialization_options = {
              nix = {
                flake = {
                  autoArchive = true;
                };
              };
            };
          };
        };

        # always use relative line numbers
        relative_line_numbers = "enabled";

        # enable regex in search by default
        search = {
          regex = true;
        };

        # show line at 80 characters
        wrap_guides = [80];

        # disable telemetry
        telemetry = {
          diagnostics = false;
          metrics = false;
        };

        # show tab file icons
        tabs = {
          file_icons = true;
        };

        terminal = {
          env = {
            EDITOR = "${zed-exe} --wait --add";
          };
        };

        vim_mode = true;
        # TODO: helix
        # helix_mode = true;
      };
    };
  };
}
