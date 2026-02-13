{
  lib,
  pkgs,
  config,
  ...
}: let
  size =
    if builtins.hasAttr "monitors" config.garden.hardware && config.garden.hardware.monitors != {}
    then
      builtins.attrValues config.garden.hardware.monitors
      |> builtins.sort (a: b: a.order < b.order)
      |> builtins.head
    else {
      width = 1920;
      height = 1080;
    };

  sizeStr = "${builtins.toString size.width}x${builtins.toString size.height}";

  image = let
    margin = 10;
    xoffset = builtins.div size.width margin;
    yoffset = builtins.div size.height margin;
    xrange = "${builtins.toString xoffset}-${builtins.toString (size.width - xoffset)}";
    yrange = "${builtins.toString yoffset}-${builtins.toString (size.height - yoffset)}";

    magick = lib.getExe pkgs.imagemagick;
    shuf = lib.getExe' pkgs.uutils-coreutils-noprefix "shuf";

    colors = config.lib.stylix.colors.withHashtag;
    pointMult = 1;
  in
    # https://usage.imagemagick.org/backgrounds/
    pkgs.runCommand "image.png" {} ''
      set -eu
      TMP="$(mktemp -d)"

      COLOURS=()
      for i in {1..${builtins.toString pointMult}}; do
        COLOURS+=("${colors.base08}" "${colors.base09}" "${colors.base0A}" "${colors.base0B}" "${colors.base0C}" "${colors.base0D}" "${colors.base0E}" "${colors.base0F}")
      done

      points=''${#COLOURS[@]}
      readarray -t xPos < <(${shuf} -n $points -i ${xrange})
      readarray -t yPos < <(${shuf} -n $points -i ${yrange})
      readarray -t xOff < <(${shuf} -n $points -i 0-${builtins.toString (xoffset * 2)})
      readarray -t yOff < <(${shuf} -n $points -i 0-${builtins.toString (yoffset * 2)})

      sparse=""
      i=0
      for colour in ''${COLOURS[@]}; do
        x=$((xPos[i] + xOff[i] - ${builtins.toString xoffset}))
        y=$((yPos[i] + yOff[i] - ${builtins.toString yoffset}))

        sparse+="$x,$y $colour "
        i=$((i + 1))
      done

      ${magick} -size ${sizeStr} -define shepherds:power=1.5 xc: -sparse-color Shepherds "$sparse" "$TMP/gradient.png"
      ${magick} -size ${sizeStr} xc: +noise random -virtual-pixel tile -blur "0x$(${shuf} -n 1 -i 10-30)" -normalize -colorspace Gray -sigmoidal-contrast 15x50% -solarize 50% -auto-level "$TMP/filaments.png"
      ${magick} "$TMP/gradient.png" "$TMP/filaments.png" -alpha off -compose copy_opacity -composite -background "${colors.base00}" -alpha remove "$out"
    '';
in {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/mountain.yaml";
    inherit image;

    fonts = {
      serif = {
        package = pkgs.b612;
        name = "b612";
      };

      sansSerif = {
        package = pkgs.b612;
        name = "b612";
      };

      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 10;
        terminal = 10;
      };
    };
  };
}
