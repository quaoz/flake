{
  lib,
  pkgs,
  ...
}: let
  # TODO: some of these don't work on zsh and should probably be refactored into scripts
  functions = ''
    mkcd() {
        mkdir -p "$@" && cd "$_";
    }

    cheat() {
        local combined="''${@}"
        ${lib.getExe pkgs.curl} cheat.sh/"''${combined// /-}";
    }

    swap() {
        mv "''${1}" "''${1}".tmp
        mv "''${2}" "''${1}"
        mv "''${1}".tmp "''${2}"
    }

    store-path() {
        local path=$(nix-instantiate --eval-only --expr '(import <nixpkgs> { system = "'"''${2:-${pkgs.stdenv.hostPlatform.system}}"'"; }).'"$1"'.outPath' 2> /dev/null)
        echo "''${path:1:-1}"
    }

    cache-has() {
        local system
        local cache
        local pargs=()
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -c|--cache)
                    cache="$2"
                    shift
                    ;;
                -s|--system)
                    system="$2"
                    shift
                    ;;
                -*|--*)
                    echo "Unknown option $1"
                    echo "Usage: $0 [options...] <file>"
                    echo " -c, --cache <cache>"
                    echo " -s, --system <system>"
                    return 1
                    ;;
                *)
                    pargs+=("$1")
                    ;;
            esac
            shift
        done
        set -- "''${pargs[@]}"

        local hash=$(store-path "$1" $system | ${lib.getExe pkgs.choose} -f '/|-' 2)
        if ${lib.getExe pkgs.curl} --output /dev/null --silent --head --fail "https://''${2-cache.nixos.org}/$hash.narinfo"; then
            echo yes
            return 0
        else
            echo no
            return 1
        fi
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
