{
  home,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # essentials
    firefox

    # utils
    spotify
    obs-studio
    xournalpp

    # UI
    # hyprland from modules

    # coding
    # vscodium from modules

    # dart
    flutter
    android-tools
    android-studio

    ## nix
    alejandra

    ## python
    conda
    ollama

    ## c
    extra-cmake-modules

    # gaming
    wine
    gnome3.adwaita-icon-theme
    steam
    flatpak
    gnome.gnome-software
  ];
}
