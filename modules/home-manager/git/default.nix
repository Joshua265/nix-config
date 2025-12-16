{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      aliases = {
        ci = "commit";
        co = "checkout";
        s = "status";
        l = "log";
        b = "branch";
        d = "diff";
        find = "grep -w";
      };
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      core.editor = "code";
      core.fsmonitor = true;
      core.untrackedCache = true;
      diff.guitool = "code";
      diff.tool = "code";
      difftool.prompt = false;
      difftool.code.cmd = "code --wait --diff $LOCAL $REMOTE";
      help.autocorrect = 30;
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      merge.guitool = "code";
      merge.tool = "code";
      mergetool.prompt = false;
      mergetool.codium.cmd = "code --wait $MERGED";
      pull.ff = "only";
      push.autoSetupRemote = true;
      rerere.enabled = true;
      user.useConfigOnly = true;
      fetch.writeCommitGraph = true;
      branch.sort = "-committerdate";
    };

    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ed25519";
    };
    lfs = {
      enable = true;
      skipSmudge = true;
    };
    ignores = [
      ".DS_Store"
      "*~"
      "*.swp"
    ];
  };
}
