{config, ...}: {
  # TODO: properly support zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    dotDir = "${config.xdg.configHome}/zsh";
  };
}
