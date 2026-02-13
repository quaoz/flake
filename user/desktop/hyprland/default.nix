{
  pkgs,
  osConfig,
  lib,
  self,
  ...
}: {
  config = lib.mkIf (pkgs.stdenv.isLinux && osConfig.garden.profiles.desktop.enable) {
    services = {
      dunst = {
        enable = true;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;

      package = null;
      portalPackage = null;

      systemd = {
        enable = true;
        variables = ["--all"];
        extraCommands = [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };

      # https://wiki.hypr.land/Configuring/
      settings = {
        input = {
          kb_layout = osConfig.services.xserver.xkb.layout;
          kb_variant = osConfig.services.xserver.xkb.variant;
        };

        # TODO: maybe move this somewhere else
        device = [
          {
            name = "mosart-varmilo-keyboard";
            kb_layout = "us";
          }
        ];

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        windowrule = [
          # bitwarden extension
          "match:title ^.*Bitwarden Password Manager.*$, float on"

          # pip
          "match:title ^(Picture-in-Picture)$, float on"
          "match:title ^(Picture-in-Picture)$, pin on"
        ];

        monitor =
          (lib.mapAttrsToList (
              n: v:
                builtins.concatStringsSep "," [
                  "${n}"
                  "${builtins.toString v.width}x${builtins.toString v.height}@${builtins.toString v.refresh-rate}"
                  "auto"
                  "${builtins.toString v.scale}"
                ]
            )
            osConfig.garden.hardware.monitors)
          ++ [
            ",preferred,auto,1"
          ];

        # allocate each monitor a continuous range of wworkspaces
        workspace = let
          monNames =
            lib.mapAttrsToList (name: value: {
              inherit (value) order;
              inherit name;
            })
            osConfig.garden.hardware.monitors
            |> builtins.sort (a: b: a.order < b.order)
            |> builtins.map (m: m.name);
          monCount = builtins.length monNames;
          q = builtins.div 10 monCount;
          r = self.lib.mod 10 monCount;
        in
          builtins.genList (
            monId: let
              start =
                if monId == 0
                then 1
                else r + (monId * count) + 1;
              count =
                if monId == 0
                then r + q
                else q;
            in
              builtins.genList (i: "${builtins.toString (start + i)}, monitor:${builtins.elemAt monNames monId}") count
          )
          monCount
          |> builtins.concatLists;
      };
    };
  };
}
