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

        deadnix.enable = true;

        just.enable = true;

        keep-sorted.enable = true;

        prettier.enable = true;

        shellcheck.enable = true;

        shfmt = {
          enable = true;
          indent_size = 0; # use tabs
        };

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
                  extend-ignore-re = [
                    # don't correct ssh keys
                    "ssh-ed25519 [a-zA-Z0-9+/]{68}"
                  ];

                  extend-words = builtins.foldl' (acc: word: acc // {${word} = word;}) {} [
                    "HELO"
                    "fo"
                    "rin"
                  ];
                };

                files.extend-exclude = ["*.age"];
              }).outPath;
          in
            self.lib.addFlags pkgs pkgs.typos "--config ${configFile}";
        };
        # keep-sorted end
      };
    };
  };
}
