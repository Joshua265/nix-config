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
  # You can import other home-manager modules here
  outputs.homeModules.vscodium
  outputs.homeModules.git
  outputs.homeModules.git-refresh

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

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
      ];
    };
  };

  # Username
  home = {
    username = "user";
    homeDirectory = "/home/user";
  };

  home.packages = with pkgs; [ 
    steam
    firefox
    discord
    conda
    spotify
    keepassxc
    obs-studio
    
    alejandra
    lspci
  ] ++ (with pkgs.gnomeExtensions;
    [
      blur-my-shell
      caffeine
      hue-lights
      night-theme-switcher
      rounded-window-corners
    ]);

  # Use `dconf watch /` to track stateful changes you are doing, then set them here.
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "blur-my-shell@aunetx"
        "caffeine@patapon.info"
        "hue-lights@chlumskyvaclav.gmail.com"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "rounded-window-corners@yilozt"
      ];
    };
  };

  # Enable home-manager 
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
