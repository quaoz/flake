{osConfig, ...}: {
  programs.home-manager.enable = true;

  home = {
    homeDirectory = osConfig.users.users.${osConfig.me.username}.home;
    stateVersion = "23.11";
  };
}
