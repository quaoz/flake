{config, ...}: let
  inherit (config.age) secrets;
in {
  config = {
    garden.secrets.root = ["nix/github-api.age"];

    nix.extraOptions = ''
      !include ${secrets.nix-github-api.path}
    '';
  };
}
