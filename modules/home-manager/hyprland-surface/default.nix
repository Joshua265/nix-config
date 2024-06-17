{
  config,
  pkgs,
  inputs,
  ...
}: let
  settings = import ./settings.nix {inherit config pkgs;};
in {
  home.packages = with pkgs; [
    libnotify # Required for dunst
    dconf # Required for gtk
    cliphist # Clipboard manager
    wl-clipboard # Cliphist dependency
    go # Required for cliphist
    xdg-utils # mimetypes
    dunst
    swww
    kitty
    alacritty
    rofi-wayland
    networkmanager
    networkmanagerapplet
    polkit-kde-agent # auth agent
    xdg-desktop-portal-hyprland
    dolphin # file manager
    wayland-protocols # hyprlock dependency
    mesa # hyprlock dependency
    iwgtk # wifi manager
    blueberry # bluetooth management
    pavucontrol # audio management
    grim # screenshot
    slurp # grim dependencies
    qt6.qtwayland # qt6 obs patch
    libglvnd
  ];
  wayland.windowManager.hyprland = {
    inherit settings;
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
    ];
  };

  # enable hyprctl
  systemd.user.services.waybar.Service.Environment = "PATH=/run/wrappers/bin:${pkgs.hyprland}/bin";

  gtk = {
    enable = true;
    theme.name = "Nordic";
    theme.package = pkgs.nordic;
  };

  ## Essential Utilities
  # xdg.portal = {
  #   enable = true;
  #   xdgOpenUsePortal = true;
  #   config = {
  #     common.default = ["gtk"];
  #     hyprland.default = ["gtk" "hyprland"];
  #   };

  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-gtk
  #   ];
  # };
}
