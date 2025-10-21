{
  description = "waow";

  nixConfig = {
    extra-experimental-features = [
      # needed for ci
      "pipe-operator"
      "pipe-operators"
    ];
  };

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

      inputs = {
        nixpkgs.follows = "nixpkgs";
        lix.follows = "lix";
        flake-utils.follows = "flake-utils";
      };
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

    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        agenix.follows = "agenix";
      };
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        devshell.follows = "devshell";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    ##### flake #####

    # nix flake deployment tool
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };

    # simpler devshells
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # lockfile linter
    locker = {
      url = "github:tgirlcloud/locker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # unified formatter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ##### other #####

    buildbot-nix = {
      url = "github:nix-community/buildbot-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        hercules-ci-effects.follows = "";
        treefmt-nix.follows = "";
      };
    };

    # declarative disk formatting
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix wrapper for dnscontrol
    dnscontrol-nix = {
      url = "git+https://codeberg.org/hu5ky/dnscontrol-nix.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        treefmt-nix.follows = "";
      };
    };

    # firefox addons
    firefox-addons = {
      url = "git+https://gitlab.com/rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # firefox nightly
    firefox-nightly = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        lib-aggregate.follows = "lib-aggregate";
        flake-compat.follows = "";
      };
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-25_05.follows = "";
        git-hooks.follows = "";
        flake-compat.follows = "";
      };
    };

    # theming framework
    stylix = {
      # TODO: revert once https://github.com/nix-community/stylix/pull/1938 is merged
      # url = "github:nix-community/stylix";
      url = "github:arunoruto/stylix/vivid";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-parts.follows = "flake-parts";
      };
    };

    ##### locker #####

    systems.url = "github:nix-systems/default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    lib-aggregate = {
      url = "github:nix-community/lib-aggregate";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs-lib.follows = "nixpkgs";
      };
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        home-manager.follows = "home-manager";
      };
    };

    ##### tempoary #####

    # TODO: remove once version supporting pipe-operator in nixpkgs (>v0.5.8)
    statix = {
      url = "github:oppiliappan/statix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
      };
    };
  };
}
