# my flake

the 4th? rewrite of my flake (mess --> [snowfall](https://snowfall.org/) --> [hive](https://github.com/divnix/hive) --> [flake-parts](https://flake.parts/))

## layout

- [`hosts/`](./hosts): per-machine configuration using [easy-hosts](https://github.com/tgirlcloud/easy-hosts)
  - [`hosts/blume/`](./hosts/blume): **blume**: installer iso
  - [`hosts/ganymede/`](./hosts/ganymede): **ganymede**: random cheap vps
  - [`hosts/nyx/`](./hosts/nyx): **nyx**: 2021 mac book pro
  - [`hosts/verenia/`](./hosts/verenia): **verenia**: 2013 ~trashcan~ mac pro
- [`modules/`](./modules): modules used by system configurations
  - [`modules/common/`](./modules/common): modules shared by all systems
  - [`modules/darwin/`](./modules/dawrin): darwin modules
  - [`modules/flake/`](./modules/flake): modules defining flake outputs
    - [`modules/flake/lib/`](./modules/flake/lib): my library functions
    - [`modules/flake/parts/`](./modules/flake/parts): [flake parts](https://flake.parts/)
  - [`modules/iso/`](./modules/iso): iso modules
  - [`modules/nixos/`](./modules/nixos): nixos modules
- [`pkgs/`](./pkgs): packages for things not in nixpkgs
- [`secrets/`](./secrets): shhhh, secrets managed with [ragenix](https://github.com/yaxitech/ragenix/) and [agenix-rekey](https://github.com/oddlama/agenix-rekey)
  - [`secrets/.rekeyed/`](./secrets/.rekeyed): rekeyed secrets
- [`user/`](./user): user environment configuration with [home-manager](https://github.com/nix-community/home-manager/)
