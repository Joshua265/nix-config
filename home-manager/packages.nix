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
    onlyoffice-bin # office suite
    thunderbird # email client
    webex
    

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
    wine
    gnome3.adwaita-icon-theme
    steam
    flatpak
    gnome.gnome-software
  ];
}
