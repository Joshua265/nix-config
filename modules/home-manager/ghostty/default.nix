{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.tmux = {
    enable = true; # installs tmux and generates config
    shell = "${pkgs.fish}/bin/fish";
    historyLimit = 500000;
    mouse = true;
  };
  programs.bash.enable = true;
  programs.fish = {
    enable = true;
    generateCompletions = true;
    interactiveShellInit = ''
      eval "$(zoxide init fish)"
      freshfetch
    '';
  };
  programs.zsh.enable = true;
  programs.starship = {
    enable = true;
    enableTransience = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$line_break"
        "$package"
        "$line_break"
        "$character"
      ];
      scan_timeout = 10;
      character = {
        success_symbol = "➜";
        error_symbol = "➜";
      };
    };
  };
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installVimSyntax = true;
    package = pkgs.ghostty;
    settings = {
      theme = "custom-base16";
      font-size = 10;
      keybind = [
        # "ctrl+h=goto_split:left"
        # "ctrl+l=goto_split:right"
        # "ctrl+n=new_window"
        # "ctrl+h=goto_split:left"
        # "ctrl+j=goto_split:bottom"
        # "ctrl+k=goto_split:top"
        # "ctrl+l=goto_split:right"

        # "ctrl+a>h=new_split:left"
        # "ctrl+a>j=new_split:down"
        # "ctrl+a>k=new_split:up"
        # "ctrl+a>l=new_split:right"
        # "ctrl+a>f=toggle_split_zoom"

        "ctrl+a>n=next_tab"
        "ctrl+a>p=previous_tab"
      ];
      # as soon as Ghostty opens, run tmux (attach if possible, else new)
      command = "tmux attach || tmux new";
    };
    themes = {
      custom-base16 = {
        background = config.colorScheme.palette.base00;
        cursor-color = config.colorScheme.palette.base07;
        foreground = config.colorScheme.palette.base05;
        palette = [
          "0=#${config.colorScheme.palette.base00}"
          "1=#${config.colorScheme.palette.base01}"
          "2=#${config.colorScheme.palette.base02}"
          "3=#${config.colorScheme.palette.base03}"
          "4=#${config.colorScheme.palette.base04}"
          "5=#${config.colorScheme.palette.base05}"
          "6=#${config.colorScheme.palette.base06}"
          "7=#${config.colorScheme.palette.base07}"
          "8=#${config.colorScheme.palette.base08}"
          "9=#${config.colorScheme.palette.base09}"
          "10=#${config.colorScheme.palette.base0A}"
          "11=#${config.colorScheme.palette.base0B}"
          "12=#${config.colorScheme.palette.base0C}"
          "13=#${config.colorScheme.palette.base0D}"
          "14=#${config.colorScheme.palette.base0E}"
          "15=#${config.colorScheme.palette.base0F}"
        ];
        selection-background = "353749";
        selection-foreground = "cdd6f4";
      };
    };
  };
}
