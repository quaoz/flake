{
  programs.helix = {
    enable = true;

    # https://docs.helix-editor.com/configuration.html
    settings = {
      editor = {
        line-number = "relative";

        auto-save = {
          focus-lost = true;
        };

        indent-guides = {
          render = true;
        };
      };
    };
  };
}
