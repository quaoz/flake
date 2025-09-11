{lib, ...}: {
  programs.starship = {
    enable = true;

    settings = {
      # use some nerd font symbols
      c.symbol = " ";
      cmake.symbol = "󰔷 ";
      conda.symbol = " ";
      git_commit.tag_symbol = " ";
      haxe.symbol = " ";
      java.symbol = " ";
      kotlin.symbol = " ";
      nim.symbol = "󰆥 ";
      nodejs.symbol = " ";
      rlang.symbol = "󰟔 ";
      ruby.symbol = " ";
      scala.symbol = " ";
      swift.symbol = " ";
      zig.symbol = " ";

      character = {
        success_symbol = "[:;](bold green)";
        error_symbol = "[:;](bold red)";
      };

      username = {
        disabled = true;
        format = "[$user]($style)";
        #show_always = true;
      };

      directory = {
        format = "in [$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 5;
        truncation_symbol = "…/";
        read_only = " 󰌾";
      };

      sudo = {
        disabled = false;
      };

      direnv = {
        # TODO: fix msg for direnv deny https://starship.rs/config/#direnv
        disabled = false;
        symbol = "env ";
        format = "$symbol[$loaded$allowed]($style) ";
        style = "bold blue";
        allowed_msg = " (allowed)";
        not_allowed_msg = " (not allowed)";
      };

      nix_shell = {
        symbol = "❄️ ";
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

      cmd_duration = {
        min_time = 50;
      };

      format = lib.concatStrings [
        "[##](bold magenta) "
        "$all"
        "$line_break"
        "$character"
      ];

      scan_timeout = 50;
      command_timeout = 1000;

      # hostname.ssh_symbol = " ";
      hostname = {
        format = "@[$hostname]($style) ";
        ssh_only = false;
        style = "bold green";
      };
    };
  };
}
