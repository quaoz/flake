{pkgs, ...}: {
  # disable all installer tools and only bring the ones that we explicitly need
  system = {
    disableInstallerTools = true;

    tools = {
      nixos-enter.enable = true;
      nixos-install.enable = true;
    };
  };

  # we only need a basic git install
  programs.git.package = pkgs.gitMinimal;
}
