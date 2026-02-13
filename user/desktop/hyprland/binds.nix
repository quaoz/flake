{
  pkgs,
  osConfig,
  lib,
  config,
  self,
  ...
}: let
  mkBind = mod: dispatcher: {
    key,
    params ? null,
    ...
  }: let
    paramstr =
      if params == null || params == "" || params == []
      then ""
      else
        ", "
        + (
          if builtins.isList params
          then builtins.concatStringsSep " " params
          else params
        );
  in "${mod}, ${key}, ${dispatcher}${paramstr}";

  mkBinds = mod: as:
    lib.mapAttrsToList (
      dispatcher: binds: let
        bindlist =
          if builtins.isAttrs binds
          then
            lib.mapAttrsToList (key: params:
              {inherit key;}
              // (
                if builtins.isAttrs params
                then params
                else {inherit params;}
              ))
            binds
          else
            builtins.map (key: {inherit key;}) (
              if builtins.isList binds
              then binds
              else [binds]
            );
      in
        builtins.map (bind: mkBind (bind.mod or mod) dispatcher bind) bindlist
    )
    as
    |> builtins.concatLists;

  withAliases = as: aliases:
    builtins.foldl' (l: alias:
      l
      // (
        if builtins.hasAttr alias.name as && ! builtins.hasAttr alias.value as
        then {${alias.value} = as.${alias.name};}
        else {}
      ))
    as
    (lib.attrsToList aliases);

  mkSubmap = n: v:
    mkBinds "" {
      ${n} = withAliases v {
        left = "h";
        up = "k";
        down = "j";
        right = "l";
      };
      submap.escape = "reset";
    };
in {
  wayland.windowManager.hyprland = lib.mkIf (osConfig.garden.profiles.desktop.enable && pkgs.stdenv.isLinux) {
    submaps = {
      move.settings.binde = mkSubmap "movewindow" {
        left = "l";
        up = "u";
        down = "d";
        right = "r";
      };

      resize.settings.binde = mkSubmap "resizeactive" {
        left = "-20 0";
        up = "0 20";
        down = "0 -20";
        right = "20 0";
      };
    };

    settings = {
      "$mod" = "SUPER";

      # 3/4 finger swipe to change workspace
      gesture = [
        "3,horizontal,workspace"
        "4,horizontal,workspace"
      ];

      # mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # locked binds
      bindl = mkBinds "" {
        exec = {
          # mute
          XF86AudioMute = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];

          # media controls
          XF86AudioPlay = ["playerctl" "play-pause"];
          XF86AudioPause = ["playerctl" "play-pause"];
          XF86AudioPrev = ["playerctl" "previous"];
          XF86AudioNext = ["playerctl" "next"];
        };
      };

      # repeating + locked binds
      bindel = mkBinds "" {
        exec = {
          # volume controls
          XF86AudioRaiseVolume = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
          XF86AudioLowerVolume = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];

          # brightness
          XF86MonBrightnessUp = ["brightnessctl" "set" "5%+" "-q"];
          XF86MonBrightnessDown = ["brightnessctl" "set" "5%-" "-q"];
        };
      };

      # normal binds
      bind = let
        wsMap = builtins.foldl' (l: r:
          l
          // {
            ${builtins.toString (self.lib.mod r 10)} = builtins.toString r;
          })
        {} (builtins.genList (x: x + 1) 10);
      in
        mkBinds "$mod" {
          # submaps
          submap = {
            M = "move";
            R = "resize";
          };

          # app binds
          exec = let
            getName = x:
              if lib.isDerivation x
              then x.meta.mainProgram
              else config.programs.${x}.package.meta.mainProgram;

            browser = getName "firefox";
            editor = getName "zed-editor";
            terminal = getName "ghostty";
            launcher = getName "vicinae";
            filemanager = getName pkgs.cosmic-files;

            grim = getName pkgs.grim;
            slurp = getName pkgs.slurp;
          in {
            B = browser;
            Z = editor;
            T = terminal;
            E = filemanager;
            Space = [launcher "toggle"];

            # screenshot
            X = [grim "-g" "\"$(${slurp} -d)\"" "-" "|" "wl-copy"];
          };

          # window controls
          killactive = "Q";
          fullscreen = "F";
          pseudo = "P";
          togglesplit = "S";
          togglefloating = "V";

          # group controls
          togglegroup = "G";
          changegroupactive = "Tab";

          # workspace controls
          workspace =
            {
              # scroll through workspaces
              mouse_down = "e+1";
              mouse_up = "e-1";
            }
            // wsMap;

          movetoworkspace =
            builtins.mapAttrs (_: params: {
              inherit params;
              mod = "$mod SHIFT";
            })
            wsMap;
        };
    };
  };
}
