{
  lib,
  self,
  inputs,
  config,
  ...
}: {
  config.nixpkgs = {
    config = {
      # don't allow aliases bcos it can get messy
      allowAliases = false;

      # explicately allow some unfree software
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "broadcom-sta"
          "claude-desktop"
          "discord"
          "discord-canary"
          "keka"
          "minecraft-server"
          "obsidian"
          "raycast"
        ];
    };

    # TODO: remove overlays
    overlays = lib.optionals (!config.garden.profiles.iso.enable) [
      inputs.lix-module.overlays.default
      self.overlays.default
    ];
  };
}
