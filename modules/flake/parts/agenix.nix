{
  inputs,
  self,
  lib,
  ...
}: let
  inherit (import ../lib/helpers.nix {inherit lib;}) hosts;
in {
  imports = [
    inputs.agenix-rekey.flakeModule
  ];

  # set hosts for agenix-rekey
  perSystem = _: {
    agenix-rekey.nixosConfigurations = hosts self {includeDarwin = true;};
  };
}
