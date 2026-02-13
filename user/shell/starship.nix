{
  programs.starship = {
    enable = true;

    settings = {
      scan_timeout = 50;
      command_timeout = 1000;

      format = builtins.concatStringsSep "" [
        "[##](bold magenta) "
        "$all"
        "$line_break"
        "$character"
      ];

      # use some nerd font symbols (see: https://starship.rs/presets/nerd-font)
      c.symbol = " ";
      cpp.symbol = " ";
      cmake.symbol = "󰔷 ";
      conda.symbol = " ";
      git_commit.tag_symbol = " ";
      golang.symbol = " ";
      gradle.symbol = " ";
      haxe.symbol = " ";
      java.symbol = " ";
      kotlin.symbol = " ";
      nim.symbol = "󰆥 ";
      nodejs.symbol = " ";
      package.symbol = "󰏗 ";
      php.symbol = " ";
      python.symbol = " ";
      rlang.symbol = "󰟔 ";
      ruby.symbol = " ";
      scala.symbol = " ";
      swift.symbol = " ";
      zig.symbol = " ";

      # keep-sorted start block=yes newline_separated=yes
      character = {
        success_symbol = "[:;](bold green)";
        error_symbol = "[:;](bold red)";
      };

      cmd_duration = {
        min_time = 500;
      };

      directory = {
        format = "in [$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 5;
        truncation_symbol = "…/";
        read_only = " 󰌾";
      };

      direnv = {
        disabled = false;
        symbol = "env ";
        format = "$symbol[$loaded$allowed]($style) ";
        style = "bold blue";
        allowed_msg = "";
        not_allowed_msg = " (not allowed)";
        denied_msg = " (denied)";
      };

      hostname = {
        format = "@[$hostname]($style) ";
        ssh_only = false;
        style = "bold green";
      };

      nix_shell = {
        symbol = " ";
        impure_msg = "[\\(]($style)[±](bold red)[\\)]($style)";
        pure_msg = "";
        format = "in [$symbol$name$state]($style) ";
      };

      status = {
        disabled = false;
        map_symbol = true;
        pipestatus = true;
        sigint_symbol = "❗";
        not_found_symbol = "❓";

        format = "[$symbol( $common_meaning)( SIG$signal_name)( $maybe_int)]($style)";
        pipestatus_separator = " | ";
        pipestatus_format = "\\[$pipestatus\\] → [$symbol($common_meaning)(SIG$signal_name)($maybe_int)]($style)";
      };

      sudo = {
        disabled = false;
      };

      username = {
        disabled = true;
        format = "[$user]($style)";
        #show_always = true;
      };

      # keep-sorted end
    };
  };
}
