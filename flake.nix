{
  description = "waow";

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} {imports = [./modules/flake];};

  inputs = {
    # https://deer.social/profile/did:plc:mojgntlezho4qt7uvcfkdndg/post/3loogwsoqok2w
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    # cooler nix
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };

    # better darwin support
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # manage user environment with nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ##### glue #####

    # cobble everything together
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # simplify host management
    easy-hosts.url = "github:tgirlcloud/easy-hosts";

    ##### shhhh #####

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ##### flake #####

    # nix flake deployment tool
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # simpler devshells
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake lockfile linter
    locker = {
      url = "github:tgirlcloud/locker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # unnified formatter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ##### other #####

    # declarative disk formatting
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix wrapper for dnscontrol
    dnscontrol-nix = {
      url = "git+https://codeberg.org/hu5ky/dnscontrol-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # firefox addons
    firefox-addons = {
      url = "git+https://gitlab.com/rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # firefox nightly
    firefox-nightly = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # firefox nightly on darwin
    firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix index database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # simple state management
    preservation.url = "github:nix-community/preservation";

    # mailserver
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # theming framework
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ##### tempoary #####

    # TODO: remove once version supporting pipe-operator in nixpkgs (>v0.5.8)
    statix = {
      url = "github:RobWalt/statix/support-pipe-operator";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
