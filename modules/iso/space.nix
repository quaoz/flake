{lib, ...}: let
  inherit (lib) mkForce mkDefault;
in {
  # disable documentation
  documentation = {
    enable = mkForce false;
    dev.enable = mkForce false;
    doc.enable = mkForce false;
    info.enable = mkForce false;
    nixos.enable = mkForce false;

    man = {
      enable = false;
      man-db.enable = false;
    };
  };

  # remove some default packages
  environment.defaultPackages = mkDefault [];

  # don't include nixpkgs in our iso
  system.installer.channel.enable = false;
}
