{
  inputs,
  pkgs,
  lib,
  ...
}: let
  obsidianWithExtras = pkgs.symlinkJoin {
    name = "obsidian-with-extras";
    paths = [pkgs.obsidian];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/obsidian \
        --prefix PATH : ${lib.makeBinPath [
        pkgs.tesseract
        pkgs.pdfannots2json
      ]}
    '';
  };
in {
  home.packages = with pkgs; [
    # essentials
    discord

    # 3D
    blender
    cura-appimage
    orca-slicer
    unstable.bambu-studio

    # essentials
    firefox
    chromium
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
    kdePackages.xwaylandvideobridge

    obsidianWithExtras
    zotero

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
