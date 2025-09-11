{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    treefmt = {
      projectRootFile = "flake.nix";

      settings = {
        global.excludes = ["*.age"];

        formatter = {
          shellcheck = {
            options = ["--shell=bash"];
          };
        };
      };

      programs = {
        # keep-sorted start block=yes newline_separated=yes
        actionlint.enable = true;

        alejandra.enable = true;

        deadnix = {
          enable = true;
          #package = inputs'.deadnix.packages.deadnix // {meta.mainProgram = "deadnix";};
        };

        just.enable = true;

        keep-sorted.enable = true;

        prettier = {
          enable = true;
          package = pkgs.prettier;
        };

        shellcheck.enable = true;

        shfmt.enable = true;

        statix = {
          enable = true;
          package = inputs'.statix.packages.statix;
        };

        typos = {
          enable = true;

          package = let
            configFile =
              ((pkgs.formats.toml {}).generate "typos" {
                default = {
                  # don't correct ssh keys
                  extend-ignore-re = ["ssh-ed25519 [a-zA-Z0-9+/]{68}"];
                };
              }).outPath;
          in
            self.lib.addFlags pkgs "typos" "--config ${configFile} --exclude '*.age' --locale en";
        };
        # keep-sorted end
      };
    };
  };
}
