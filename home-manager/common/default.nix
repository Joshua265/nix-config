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

    outputs.homeManagerModules.git
    outputs.homeManagerModules.vscodium
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
    outputs.homeManagerModules.sioyek-obsidian
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
  programs.git = {
    userEmail = "Joshua_Noel@gmx.de";
    userName = "Joshua265";
  };

  programs.sioyekObs = {
    enable = true;
    vaultPath = /home/user/Nextcloud/notes;
    notesSubdir = "papers"; # optional
    sharedDbRelative = "Sioyek/shared.db"; # optional
    # Add or override Sioyek prefs if you like:
    extraPrefs = {
      dark_mode = "1";
      trim_margins_on_startup = "1";
      fit_to_page_mode = "1";
      smooth_scrolling = "1";
    };
    extraKeys = ''
      # Example: faster zoom and navigation
      map z zoom_in
      map Z zoom_out
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  colorScheme = nix-colors.colorSchemes.mellow-purple;

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
  home.stateVersion = "25.05";
}
