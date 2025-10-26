{
  lib,
  pkgs,
  ...
}: let
  functions = ''
    mkcd() {
        mkdir -p "$*" && cd "$_"
    }

    cheat() {
        local IFS='-'
        ${lib.getExe pkgs.curl} "cheat.sh/$*"
    }

    urlencode() {
        ${lib.getExe pkgs.jq} -r '@uri' <<<"\"$1\""
    }

    urldecode() {
        local s="''${*//+/ }"
        echo -e "''${s//%/\\x}"
    }

    swap() {
        mv "$1" "$1.tmp"
        mv "$2" "$1"
        mv "$1.tmp" "$2"
    }

    colours() {
        local i
        local char="''${1:-█}"
        for i in {0..256}; do
            if ((i % 16 == 0)); then
                printf '\n'
            fi
            printf "\x1b[38;5;''${i}m''${char}"
        done
        tput sgr0
    };

    truecolor-rainbow() {
        local i r g b
        for ((i = 0; i < 77; i++)); do
            r=$((255 - (i * 255 / 76)))
            g=$((i * 510 / 76))
            b=$((i * 255 / 76))
            ((g > 255)) && g=$((510 - g))
            printf '\033[48;2;%d;%d;%dm ' "$r" "$g" "$b"
        done
        tput sgr0
        echo
    }
  '';
in {
  programs = {
    bash.bashrcExtra = functions;
    zsh.initContent = functions;
  };
}
