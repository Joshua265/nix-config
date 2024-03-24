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
    webex
    whatsapp-for-linux

    # 3D
    blender
    freecad
    cura

    # 2D
    krita

    # UI
    # hyprland from modules
    # waybar from modules

    # coding
    # vscodium from modules
    # personal.zed-editor

    # dart
    flutter
    android-tools
    android-studio

    ## nix
    alejandra

    ## python
    (pkgs.python310.withPackages (python-pkgs: [
      python-pkgs.pip
      python-pkgs.pandas
      python-pkgs.requests
      python-pkgs.beautifulsoup4
      python-pkgs.numpy
      python-pkgs.scipy
      python-pkgs.matplotlib
      python-pkgs.pytorch
      python-pkgs.pydantic
      python-pkgs.flask
      python-pkgs.flask-cors
      python-pkgs.ipykernel
    ]))
    ollama

    ## c
    extra-cmake-modules

    ## unity
    unityhub

    # gaming
    openhmd
    monado
    openvr
    wine
    gnome3.adwaita-icon-theme
    steam
    (steam.override {
      extraPkgs = pkgs: [monado openhmd];
    })
    .run
    flatpak
    gnome.gnome-software
  ];
}
