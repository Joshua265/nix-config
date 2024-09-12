{
  config,
  pkgs,
  ...
}: {
  home.file.".config/alacritty/cyberdream.toml".source = ./cyberdream.toml;
  programs.alacritty = {
    enable = true;
    settings = {
      import = ["~/.config/alacritty/cyberdream.toml"];
      env.TERM = "xterm-256color";
      window.padding = {
        x = 10;
        y = 10;
      };
      window.decorations = "none";
      font = {
        normal = {
          family = "JetBrains Mono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrains Mono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono Nerd Font";
          style = "Italic";
        };
        size = 14;
      };
    };
  };
}
