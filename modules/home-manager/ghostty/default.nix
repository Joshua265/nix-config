{
  pkgs,
  config,
  ...
}: {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installVimSyntax = true;
    package = pkgs.ghostty;
    settings = {
      theme = "custom-base16";
      font-size = 10;
      keybind = [
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"
      ];
      custom-shader-animation = true;
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
