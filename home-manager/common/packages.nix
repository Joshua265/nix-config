{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # essentials
    # essentials defined in configuration.nix
    discord

    # 3D
    blender
    (freecad-wayland.overrideAttrs (final: prev: {
      postFixup = prev.postFixup;
      # ''
      # ./configure CXXFLAGS="-D_OCC64"
      # ''
      # + prev.postFixup;
    }))
    legacy.cura
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

    # utils
    spotify

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
    xwaylandvideobridge

    # 2D
    krita
    unstable.figma-linux

    # music & DAW
    audacity

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
  ];
}
