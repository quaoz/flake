{pkgs, ...}: {
  programs.bash = {
    enable = true;

    # enable bash completions
    enableCompletion = true;

    # remove duplicate commands from history
    historyControl = ["erasedups" "ignoredups"];

    # commands to omit from history
    historyIgnore = ["ls" "eza" "tree" "clear" "fg" "bg" "history" "pwd"];

    shellOptions = [
      # automatically cd if command is a directory
      "autocd"

      # attempt to correct minor errors in cd command
      "cdspell"

      # list status of jobs before exiting shell
      "checkjobs"

      # update $LINES and $COLUMNS after non-builtin commands
      "checkwinsize"

      # attempt to save multi-line commands
      "cmdhist"

      # attempt to correct directory names during word completion
      "dirspell"

      # enable extended pattern matching
      "extglob"

      # '**' will match all files and zero or more directories and subdirectories
      "globstar"

      # don't overwrite history
      "histappend"

      # enable case insensitive file matching
      "nocaseglob"
    ];
  };

  home.packages = with pkgs; [
    bash-completion
  ];
}
