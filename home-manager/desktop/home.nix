# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{pkgs, ...}: {
  # Import home-manager modules here
  imports = [
    ../common
    ./packages.nix
  ];

  home.shellAliases = {
    rebuild = "~/Documents/nix-config/rebuild-desktop.sh";
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-3, 5120x1440@120, 0x0, 1"
    "HDMI-A-3, 1920x1080@60, 0x1440, 1"
  ];

  wayland.windowManager.hyprland.settings.plugin.exec-once = ''${pkgs.xorg.xrandr}/bin/xrandr --output DP-3 --primary'';

  waybar.keyboard-name = "zsa-technology-labs-moonlander-mark-i-keyboard";
}
