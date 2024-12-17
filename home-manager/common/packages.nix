{
  home,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # essentials
    # essentials defined in configuration.nix
    discord

    # 3D
    blender
    unstable.freecad-wayland
    legacy.cura

    # essentials
    firefox
    chromium
    vlc
    libsForQt5.plasma-systemmonitor
    zathura

    # utils
    (pkgs.writeShellScriptBin "spotify" ''
      exec ${pkgs.spotify}/bin/spotify --disable-gpu "$@"
    '')

    # obs and dependencies
    obs-studio
    slurp # for screen recording

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

    adwaita-icon-theme
  ];
}
