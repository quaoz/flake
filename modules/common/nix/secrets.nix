{
  lib,
  config,
  ...
}: let
  inherit (config.age) secrets;
in {
  config = {
    garden.secrets = {
      intermediary = ["api/github.age"];
      user = ["services/attic/normal-token.age"];

      normal = {
        nix-netrc.generator = {
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

        nix-access-tokens.generator = {
          dependencies.github = secrets.api-github;

          script = {
            deps,
            decrypt,
            ...
          }: ''
            echo "access-tokens = github.com=$(${decrypt} ${lib.escapeShellArg deps.github.file})"
          '';
        };
      };
    };

    nix = {
      settings = {
        netrc-file = secrets.nix-netrc.path;
      };

      extraOptions = ''
        !include ${secrets.nix-access-tokens.path}
      '';
    };
  };
}
