{pkgs, ...}: {
  home.packages = with pkgs; [
    jq
  ];

  programs.rofi = {
    enable = true;
    terminal = "alacritty";
    cycle = true;
  };

  home.file.".config/rofi" = {
    source = ./config; # Path to the custom directory
    recursive = true; # Symlink the whole directory
  };
}
