{
  config,
  lib,
  self,
  pkgs,
  osConfig,
  ...
}: let
  inherit (osConfig.users.users.${osConfig.me.username}) shell;

  mkIfEnabled = program: content:
    lib.mkIf (self.lib.isEnabled config program) content;
in {
  home.shellAliases = lib.mkMerge [
    # generic aliases
    {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "flake" = "cd \"\${FLAKE:-$HOME/.config/flake}\"";

      "sudo" = "sudo ";
      "reload" = "exec ${shell} -l";

      ":q" = "exit";
      "ed" = "$EDITOR";

      "dog" = "doggo";
      "myip" = "${lib.getExe' pkgs.dnsutils "dig"} +short myip.opendns.com @resolver1.opendns.com";
      "serve" = "${lib.getExe pkgs.python3Minimal} -m http.server";
    }

    # desktop specific aliases
    (lib.mkIf osConfig.garden.profiles.desktop.enable {
      dt = "cd ~/Desktop";
      dl = "cd ~/Downloads";
      doc = "cd ~/Documents";
    })

    # darwin specific aliases
    (lib.mkIf pkgs.stdenv.isDarwin {
      deq = "sudo xattr -r -d com.apple.quarantine";
    })

    # eza specific aliases
    (mkIfEnabled "eza" {
      l = "eza";
      ll = "eza --long";
      lt = "eza --tree --git-ignore";
      lsd = "eza --only-dirs";
      lsf = "eza --only-files";
    })

    # stop calling zed zeditor
    (mkIfEnabled "zed-editor" {
      zed = "${lib.getExe config.programs.zed-editor.package}";
    })

    # fake htop
    (mkIfEnabled "bottom" {
      htop = "${lib.getExe config.programs.bottom.package} -b";
    })
  ];
}
