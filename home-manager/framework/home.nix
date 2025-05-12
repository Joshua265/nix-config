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
    rebuild = "~/Documents/nix-config/rebuild-framework.sh";
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1, 2256x1504@60, 0x0, 1"
    ",preferred,auto,1,mirror,eDP-1"
  ];

  waybar.keyboard-name = "at-translated-set-2-keyboard";
}
