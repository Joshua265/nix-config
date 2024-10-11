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
    libsForQt5.plasma-systemmonitor
    zathura

    # utils
    spotify
    obs-studio
    xournalpp
    onlyoffice-bin # office suite
    thunderbird # email client
    teams-for-linux
    whatsapp-for-linux
    webex
    unstable.obsidian
    xwaylandvideobridge

    # 2D
    krita
    unstable.figma-linux

    # music & DAW
    audacity

    # coding
    # vscodium from modules
    unstable.zed-editor
    unstable.terraform

    ## nix
    alejandra

    ## c
    extra-cmake-modules

    ## unity
    unityhub

    gnome3.adwaita-icon-theme
  ];
}
