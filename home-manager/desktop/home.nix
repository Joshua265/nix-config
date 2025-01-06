# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  self,
  ...
}: {
  # Import home-manager modules here
  imports = [
    ../common
    ./packages.nix
    outputs.homeManagerModules.adour
  ];

  home.shellAliases = {
    rebuild = "~/Documents/nix-config/rebuild-desktop.sh";
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "HDMI-A-3, 1920x1080@60, 0x1440, 1"
    # "HDMI-A-4, 2560x1440@60, 5120x0, 1, transform, 3"
    "DP-3, 5120x1440@120, 0x0, 1"
    # "DP-3, addreserved, 0, 0, 52, 0" # for eww sidebar
  ];

  waybar.keyboard-name = "zsa-technology-labs-moonlander-mark-i-keyboard";
}
