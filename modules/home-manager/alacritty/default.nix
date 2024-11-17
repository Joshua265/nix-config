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
          family = "GeistMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "GeistMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "GeistMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "GeistMono Nerd Font";
          style = "Bold Italic";
        };
        size = 14;
      };
    };
  };
}
