{self, ...}: {
  imports = self.lib.nixFiles' ./default.nix [./nix/repl-overlay.nix];
}
