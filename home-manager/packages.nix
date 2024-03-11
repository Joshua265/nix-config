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

    # UI
    # hyprland from modules

    # coding
    # vscodium from modules

    ## nix
    alejandra

    ## python
    conda

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # gaming
    wine
    gnome3.adwaita-icon-theme
    steam
    (lutris.override {
      extraPkgs = pkgs: [
        gamescope
        winetricks
      ];
      extraLibraries = pkgs: [
        gamescope
      ];
    })
  ];
}
