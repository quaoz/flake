{
  self,
  self',
  inputs,
  inputs',
  config,
  ...
}: {
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "hm-back";

    extraSpecialArgs = {
      inherit self self' inputs inputs';
    };

    users.${config.me.username} = {
      imports = self.lib.nixFiles ./default.nix;
    };
  };
}
