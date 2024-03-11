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
    outputs.homeManagerModules.git
    outputs.homeManagerModules.vscodium
    outputs.homeManagerModules.hyprland
  ];

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

  home.packages = with pkgs; [
    firefox
    conda
    spotify
    keepassxc
    obs-studio

    alejandra

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # gaming
    wine
    gnome3.adwaita-icon-theme
    steam
    (lutris.override {
      extraPkgs = pkgs: [
        gamescope
        winetricks
      ];
      extraLibraries = pkgs: [
        gamescope
      ];
    })
  ];

  home.sessionVariables = {
    EDITOR = "codium";
  };

  # Shell Aliases
  home.shellAliases = {
    code = "codium";
    nix-profile-ls = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
