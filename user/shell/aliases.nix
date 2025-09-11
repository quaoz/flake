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
      "flake" = "cd \"$FLAKE\"";

      "sudo" = "sudo ";
      "reload" = "exec ${shell} -l";

      ":q" = "exit";
      "ed" = "$EDITOR";

      "dog" = "doggo";
      "myip" = "${lib.getExe' pkgs.dnsutils "dig"} +short myip.opendns.com @resolver1.opendns.com";
      "serve" = "${lib.getExe pkgs.python3Minimal} -m http.server";
    }

    # darwin specific aliases
    (lib.mkIf pkgs.stdenv.isDarwin {
      dt = "cd ~/Desktop";
      dl = "cd ~/Downloads";
      doc = "cd ~/Documents";
      prj = "cd ~/Projects";

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
