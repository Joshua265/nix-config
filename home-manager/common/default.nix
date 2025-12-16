{
  inputs,
  outputs,
  nix-colors,
  pkgs,
  ...
}: {
  imports = [
    ./packages.nix

    nix-colors.homeManagerModules.default

    inputs.zen-browser.homeModules.beta

    outputs.homeManagerModules.git
    # outputs.homeManagerModules.vscodium
    outputs.homeManagerModules.vscode
    outputs.homeManagerModules.alacritty
    outputs.homeManagerModules.wlogout
    outputs.homeManagerModules.hyprlock
    outputs.homeManagerModules.nextcloud-client
    outputs.homeManagerModules.keepassxc
    outputs.homeManagerModules.hyprland
    outputs.homeManagerModules.waybar
    outputs.homeManagerModules.rofi
    outputs.homeManagerModules.ghostty
    outputs.homeManagerModules.yazi
    outputs.homeManagerModules.adour
    outputs.homeManagerModules.starship
    outputs.homeManagerModules.okular-obsidian
    outputs.homeManagerModules.mako
    outputs.homeManagerModules.zen
    outputs.homeManagerModules.syncthing
    outputs.homeManagerModules.quickshell
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
      # allowUnfreePredicate = _: true;
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
  programs.git.settings.user = {
    email = "Joshua_Noel@gmx.de";
    name = "Joshua265";
  };

  programs.okularObs = {
    enable = true;
    vaultPath = /home/user/Nextcloud/notes;
    notesSubdir = "papers"; # optional
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  colorScheme = {
    slug = "robotic-mermaid";
    name = "Robotic Mermaid";
    author = "Joshua Hermann";
    variant = "dark";
    palette = {
      base00 = "#181818";
      base01 = "#002122";
      base02 = "#034a4c";
      base03 = "#106f71";
      base04 = "#269093";
      base05 = "#44aeb1";
      base06 = "#6ac8cb";
      base07 = "#98dfe1";
      base08 = "#cff3f3";
      base09 = "#d76d6a";
      base0A = "#b0893b";
      base0B = "#73a83c";
      base0C = "#46b66c";
      base0D = "#41acaf";
      base0E = "#698fdd";
      base0F = "#a571dc";
    };
  };

  # Shell Aliases
  home.shellAliases = {
    cdnix = "cd ~/Documents/nix-config";
    code = "codium";
    nvim = "nix run github:Joshua265/neovim --";
    gparted = "sudo -E gparted"; # wayland workaround
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
