{pkgs, ...}: {
  home.packages = with pkgs; [
    jq
  ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "alacritty";
    cycle = true;
  };

  home.file.".config/rofi" = {
    source = ./config; # Path to the custom directory
    recursive = true; # Symlink the whole directory
  };
}
