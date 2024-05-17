{
  home,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # essentials
    # essentials defined in configuration.nix

    # essentials
    firefox
    chromium
    vlc

    # utils
    spotify
    obs-studio
    xournalpp
    onlyoffice-bin # office suite
    thunderbird # email client
    whatsapp-for-linux
    unstable.obsidian

    # 2D
    krita

    # UI
    # hyprland from modules
    # waybar from modules

    # coding
    # vscodium from modules

    # dart
    flutter
    android-tools
    android-studio

    ## nix
    alejandra

    ## c
    extra-cmake-modules

    ## unity
    unityhub

    # gaming
    wine
    gnome3.adwaita-icon-theme
    steam
  ];
}
