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
    outputs.homeManagerModules.hyprland-surface
    outputs.homeManagerModules.waybar-surface
  ];
  home.shellAliases = {
    rebuild = "~/Documents/nix-config/rebuild-surface.sh";
  };
}
