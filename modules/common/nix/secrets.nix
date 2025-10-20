{
  lib,
  config,
  ...
}: let
  inherit (config.age) secrets;
in {
  config = {
    garden.secrets = {
      user = [
        "api/github.age"
        "services/attic/normal-token.age"
      ];

      normal.nix-netrc.generator = {
        dependencies.attic = secrets.attic-normal-token;

        script = {
          deps,
          decrypt,
          ...
        }: ''
          echo "machine cache.${config.garden.domain}"
          echo "password $(${decrypt} ${lib.escapeShellArg deps.attic.file})"
        '';
      };
    };

    nix = {
      settings = {
        netrc-file = secrets.nix-netrc.path;
      };

      extraOptions = ''
        !include ${secrets.api-github.path}
      '';
    };
  };
}
