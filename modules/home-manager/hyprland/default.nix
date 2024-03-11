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
    dunst
    swww
    kitty
    alacritty
    wofi
    networkmanager
    networkmanagerapplet
    polkit-kde-agent # auth agent
    xdg-desktop-portal
    (
      waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      })
    )
  ];
  wayland.windowManager.hyprland = {
    inherit settings;
    enable = true;
    enableNvidiaPatches = true;
    xwayland.enable = true;
    # plugins = [
    #   inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
    # ];
  };

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
