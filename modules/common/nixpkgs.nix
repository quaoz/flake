{
  lib,
  self,
  inputs,
  ...
}: {
  config.nixpkgs = {
    config = {
      # don't allow aliases bcos it can get messy
      allowAliases = false;

      # explicately allow some unfree software
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # keep-sorted start
          "broadcom-sta"
          "claude-desktop"
          "discord"
          "discord-canary"
          "keka"
          "minecraft-server"
          "obsidian"
          "raycast"
          "widevine-cdm"
          # keep-sorted end
        ];
    };

    # TODO: remove overlays
    overlays = [
      inputs.lix-module.overlays.default
      self.overlays.default
    ];
  };
}
