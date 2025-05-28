{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  settings = import ./settings.nix {inherit inputs config pkgs lib;};
in {
  home.packages = with pkgs; [
    libnotify # Required for dunst
    dconf # Required for gtk
    cliphist # Clipboard manager
    wl-clipboard # Cliphist dependency
    go # Required for cliphist
    xdg-utils # mimetypes
    mako
    swww
    kitty
    alacritty
    networkmanager
    networkmanagerapplet
    iwgtk # wifi management
    blueberry # bluetooth management
    pavucontrol # audio management
    grim # screenshot
    slurp # grim dependencies
    qt6.qtwayland # qt6 obs patch
    xwayland # xwayland
    catppuccin-cursors.mochaMauve
    xdg-desktop-portal
    brightnessctl
  ];
  wayland.windowManager.hyprland = {
    inherit settings;
    enable = true;
    xwayland.enable = true;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    plugins = [
      inputs.hyprgrass.packages.${pkgs.system}.default
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];
  };

  # manually set env variables
  home.sessionVariables = {
    # XDG
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    # QT
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # add hyprcursor themes to env
  systemd.user.services.hyprland.Service.Environment = "HYPRCURSOR_THEME=catppuccin-mocha-mauve-cursors;HYPRCURSOR_SIZE=24;XCURSOR=catppuccin-mocha-mauve-cursors;XCURSOR_SIZE=24;WLR_NO_HARDWARE_CURSORS=1;_JAVA_AWT_WM_NONREPARENTING=1";

  # enable hyprctl
  systemd.user.services.waybar.Service.Environment = "PATH=${pkgs.hyprland}/bin";

  gtk = {
    enable = true;
    theme.name = "Nordic";
    theme.package = pkgs.nordic;

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "IBM Plex Mono";
      size = 11;
    };
  };

  ## Essential Utilities
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
      pantheon = {
        default = [
          "pantheon"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
      };
      x-cinnamon = {
        default = [
          "xapp"
          "gtk"
        ];
      };
    };

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      # inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
    ];
  };

  # use KDE filepicker
  # home.file.".config/xdg-desktop-portal/hyprland-portals.conf".source = ''
  #   [preferred]
  #   default = hyprland;gtk
  #   org.freedesktop.impl.portal.FileChooser = kde
  # '';
}
