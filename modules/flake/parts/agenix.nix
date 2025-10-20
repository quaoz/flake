{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.agenix-rekey.flakeModule
  ];

  # set hosts for agenix-rekey
  perSystem = _: {
    agenix-rekey.nixosConfigurations = self.lib.hosts self {includeDarwin = true;};
  };
}
