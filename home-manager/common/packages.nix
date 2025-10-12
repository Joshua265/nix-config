{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # essentials
    discord

    # 3D
    blender
    cura-appimage
    orca-slicer

    # essentials
    firefox
    chromium
    inputs.zen-browser.packages.${pkgs.system}.default
    vlc
    libsForQt5.plasma-systemmonitor
    zathura
    keymapp
    eduvpn-client

    kdePackages.kio-admin
    kdePackages.dolphin

    # utils
    unstable.spotify-qt
    unstable.spotify
    librespot

    # obs and dependencies
    obs-studio
    slurp # for screen recording

    marp-cli
    xournalpp
    onlyoffice-bin # office suite
    thunderbird # email client
    teams-for-linux
    whatsapp-for-linux
    webex
    unstable.obsidian
    kdePackages.xwaylandvideobridge

    # 2D
    krita
    unstable.figma-linux

    # music & DAW
    audacity
    musescore

    # coding
    # vscodium from modules
    # unstable.zed-editor
    unstable.terraform

    ## nix
    alejandra

    ## c
    extra-cmake-modules

    ## Game Development
    unityhub
    unstable.godot_4

    adwaita-icon-theme

    #custom
    youtube-transcribe
  ];
}
