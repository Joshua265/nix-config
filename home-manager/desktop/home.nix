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
}: let
  packages = import ./packages.nix {
    inherit inputs outputs lib config pkgs self;
  };
in {
  # Import home-manager modules here
  imports = [
    packages
    outputs.homeManagerModules.adour
    outputs.homeManagerModules.git
    outputs.homeManagerModules.vscodium
    outputs.homeManagerModules.hyprland
    outputs.homeManagerModules.keepassxc
    outputs.homeManagerModules.alacritty
    # outputs.homeManagerModules.eww
    outputs.homeManagerModules.waybar
    outputs.homeManagerModules.wlogout
    outputs.homeManagerModules.hyprlock
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.personal-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
      # allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      #   "discord"
      #   "spotify"
      #   "steam-original"
      #   "steam"
      # ];
    };
  };

  # Username
  home = {
    username = "user";
    homeDirectory = "/home/user";
  };

  programs.git = {
    userEmail = "Joshua_Noel@gmx.de";
    userName = "Joshua265";
  };

  home.sessionVariables = {
    EDITOR = "codium";
  };

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  # Shell Aliases
  home.shellAliases = {
    cdnix = "cd ~/Documents/nixos-config && codium ~/Documents/nixos-config";
    rebuild = "~/Documents/nixos-config/rebuild.sh";
    code = "codium";
    nix-profile-ls = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    gparted = "sudo -E gparted"; # wayland workaround
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
