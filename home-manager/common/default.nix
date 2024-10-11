{
  outputs,
  pkgs,
  ...
}: {
  imports = [
    ./packages.nix
    outputs.homeManagerModules.git
    outputs.homeManagerModules.vscodium
    outputs.homeManagerModules.alacritty
    outputs.homeManagerModules.wlogout
    outputs.homeManagerModules.hyprlock
    outputs.homeManagerModules.hypridle
    outputs.homeManagerModules.nextcloud-client
    outputs.homeManagerModules.keepassxc
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

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.bash.enable = true;
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
  home.stateVersion = "24.05";
}
