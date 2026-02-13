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

      mutableUserKeymaps = false;
      mutableUserSettings = false;
      mutableUserTasks = false;

      extensions = [
        # keep-sorted start
        "assembly"
        "basher"
        "git-firefly"
        "ini"
        "just"
        "make"
        "nix"
        "qml"
        "toml"
        # keep-sorted end
      ];

      extraPackages = with pkgs; [
        asm-lsp
        bash-language-server
        just-lsp
        qt6.qtdeclarative
        quickshell
        nil
        ruff
        shellcheck
        shfmt
        ty
        vscode-langservers-extracted
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
              "save ctrl-c"
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
          rust-analyzer = {
            # https://rust-analyzer.github.io/book/configuration.html
            initialization_options = {
              assist = {
                preferSelf = true;
              };
            };
          };
          qml = {
            binary = {
              arguments = ["-E"];
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
      };
    };
  };
}
