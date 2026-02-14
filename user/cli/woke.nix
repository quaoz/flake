{
  pkgs,
  lib,
  self,
  ...
}: {
  # modern replacements for various tools
  home.packages = with pkgs; [
    # dd --> caligula
    caligula

    # cut (and sometimes awk) --> choose
    choose

    # du --> dust
    dust

    # df --> duf
    duf

    # jq --> jql
    jql

    # tar | zip | ... --> ouch
    (ouch.override {enableUnfree = true;})

    # ps --> procs
    procs

    # sed --> sd
    sd

    # cloc --> tokei
    tokei

    uutils-coreutils-noprefix
    uutils-diffutils
    uutils-findutils
  ];

  programs = {
    # cat --> bat
    bat = {enable = true;};

    # top --> bottom
    bottom = {enable = true;};

    # tree (kinda) --> broot
    broot = {enable = true;};

    # ls --> eza
    eza = {
      enable = true;
      icons = "auto";
      git = true;

      extraOptions = [
        "--all"
        "--header"
        "--no-permissions"
        "--octal-permissions"
        "--sort=type"
        "--classify=auto"
      ];
    };

    # find --> fd
    fd = {
      enable = true;
      hidden = true;

      ignores = [
        ".git/"
        ".direnv/"
      ];
    };

    # idrk
    fzf = {
      enable = true;

      defaultCommand = "fd --type file --hidden --follow --strip-cwd-prefix --exclude .git";
      defaultOptions = [
        "--height=30%"
        "--layout=reverse"
        "--info=inline"
      ];
    };

    # neofetch --> hyfetch
    hyfetch = {
      enable = true;
      # otherwise tries to read config from `~/Library/Application\ Support/hyfetch.json`
      package = lib.mkIf pkgs.stdenv.isDarwin (
        self.lib.addFlags pkgs pkgs.hyfetch "--config-file $XDG_CONFIG_HOME/hyfetch.json"
      );

      settings = {
        auto_detect_light_dark = true;
        backend = "neofetch";
        color_align = {
          mode = "horizontal";
        };
        light_dark = "dark";
        lightness = 0.6;
        mode = "rgb";
        preset = "transgender";
        pride_month_disable = false;
      };
    };

    # grep --> rg
    ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--max-columns=150"
        "--max-columns-preview"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };

    # cd --> z
    zoxide = {
      enable = true;
      options = ["--cmd cd"];
    };
  };
}
