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
  ];
  home.shellAliases = {
    rebuild = "~/Documents/nix-config/rebuild-surface.sh";
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1, 2736x1824@60, 0x0, 1.5"
    ",preferred,auto,1,mirror,eDP-1"
  ];
}
