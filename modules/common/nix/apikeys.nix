{config, ...}: let
  inherit (config.age) secrets;
in {
  config = {
    garden.secrets.root = ["api/github.age"];

    nix.extraOptions = ''
      !include ${secrets.api-github.path}
    '';
  };
}
