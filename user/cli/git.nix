{osConfig, ...}: let
  inherit (osConfig.age) secrets;

  # TODO: put this somewhere else
  user = {
    name = "quaoz";
    email = "74419801+quaoz@users.noreply.github.com";
    signingkey = secrets.ssh-github.path;
  };
in {
  programs.git = {
    enable = true;

    lfs.enable = true;
    ignores = [
      ".cargo/"
      ".direnv/"
      ".DS_Store"
      "*.ignoreme"
    ];

    settings = {
      inherit user;

      pull = {
        rebase = true;
      };

      fetch = {
        prune = true;
      };

      apply = {
        whitespace = "fix";
      };

      branch = {
        sort = "-committerdate";
      };

      core = {
        whitespace = "trailing-space,-indent-with-non-tab,space-before-tab";
        untrackedCache = true;
        autocrlf = "input";
      };

      init = {
        defaultBranch = "main";
      };

      push = {
        autoSetupRemote = true;
        default = "simple";
        followTags = true;
      };

      gpg.format = "ssh";
      commit.gpgsign = true;

      # mostly stolen from https://github.com/hawkw/flake/blob/main/modules/home/profiles/git.nix
      alias = {
        # list all aliases
        aliases = "config --get-regexp '^alias.'";

        # shorthand
        co = "checkout";
        ci = "commit";
        rb = "rebase";
        rbct = "rebase --continue";
        please = "push --force-with-lease";
        commend = "commit --amend --no-edit";

        # nicer commit and branch verbs
        squash = "merge --squash";

        # get the current branch name
        branch-name = "!git rev-parse --abbrev-ref HEAD";

        # push the current branch to the remote "origin", and set it to track the upstream branch
        publish = "!git push -u origin $(git branch-name)";

        # delete the remote version of the current branch
        unpublish = "!git push origin :$(git branch-name)";

        # sign the last commit
        sign = "commit --amend --reuse-message=HEAD -sS";

        # undo commits
        uncommit = "reset --hard HEAD";

        # logs
        lt = "log --graph --oneline --decorate --all";
        summarise-branch = ''
          log --pretty=format:'* %h %s%n%n%w(72,2,2)%bz' --decorate
        '';
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";

        # status
        st = "status --short --branch";
        stu = "status -uno";

        pr = "!pr() { git fetch origin pull/$1/head:pr-$1; git checkout pr-$1; }; pr";
      };
    };
  };
}
