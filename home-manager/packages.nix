{
  home,
  pkgs,
  ...
}: {
  # Spotify track sync with other devices
  networking.firewall.allowedTCPPorts = [57621];
  home.packages = with pkgs; [
    # essentials
    firefox

    # utils
    spotify
    keepassxc
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
