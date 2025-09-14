{osConfig, ...}: {
  programs.atuin = {
    enable = true;

    flags = ["--disable-up-arrow"];
    settings = {
      dialect = "uk";
      show_preview = true;
      inline_height = 30;
      style = "compact";
      sync_address = "https://atuin.internal.${osConfig.garden.domain}";
      sync_frequency = "5m";
      update_check = false;
    };
  };
}
