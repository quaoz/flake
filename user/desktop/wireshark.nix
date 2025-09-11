{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # TODO: automatically chmodBPF on darwin
  home.packages = with pkgs;
    lib.optionals osConfig.garden.profiles.desktop.enable [
      wireshark
    ];
}
