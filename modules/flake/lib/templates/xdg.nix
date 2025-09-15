# TODO: xdg-ninja, https://github.com/isabelroses/dotfiles/blob/main/modules/flake/lib/template/xdg.nix
let
  XDG_CONFIG_HOME = "$HOME/.config";
  XDG_CACHE_HOME = "$HOME/.cache";
  XDG_DATA_HOME = "$HOME/.local/share";
  XDG_STATE_HOME = "$HOME/.local/state";
  XDG_BIN_HOME = "$HOME/.local/bin";
  XDG_RUNTIME_DIR = "/run/user/$UID";
in {
  templates.xdg = {
    global = {
      inherit
        XDG_CONFIG_HOME
        XDG_CACHE_HOME
        XDG_DATA_HOME
        XDG_STATE_HOME
        XDG_BIN_HOME
        XDG_RUNTIME_DIR
        ;

      PATH = ["$bin"];
    };
  };
}
