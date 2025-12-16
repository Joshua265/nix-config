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
  touchScript = "$HOME/.config/zathura/touch_next.py";
in {
  # Import home-manager modules here
  imports = [
    outputs.homeManagerModules.git
    outputs.homeManagerModules.alacritty
    outputs.homeManagerModules.nextcloud-client
    outputs.homeManagerModules.keepassxc
    ./packages.nix
  ];
  home.shellAliases = {
    rebuild = "~/Documents/nix-config/rebuild-surface.sh";
  };

  # Ensure GDM’s greeter also has the on-screen keyboard turned on
  # by adding a small systemd service that writes the dconf key as the gdm user
  # systemd.user.services.gdm-onboard = {
  #   description = "Enable GNOME on-screen keyboard for GDM";
  #   serviceConfig = {
  #     User = "gdm";
  #     ExecStart = "${pkgs.dconf}/bin/dconf write /org/gnome/desktop/a11y/applications/screen-keyboard-enabled true";
  #     Type = "oneshot";
  #   };
  # };

  # turn on HM’s X session
  xsession = {
    enable = true;
    windowManager.command = "gnome-session";
    initExtra = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --rotate left &
      ${touchScript} &
    '';
  };

  # 2) Zathura config
  home.file."/.config/zathura/zathurarc".text = ''
    map <F14> feedkeys "<C-d>"
  '';

  home.file."${touchScript}" = {
    text = ''
      #!/usr/bin/env python3
      import evdev, subprocess

      # Adjust to match your touchscreen event node (run `ls /dev/input/by-path/`)
      dev = evdev.InputDevice('/dev/input/event6')

      # Rightmost 10% threshold (e.g. 2736 px wide in portrait)
      WIDTH = dev.capabilities().get(evdev.ecodes.EV_ABS, {})\
              .get(evdev.ecodes.ABS_X, (0, 2736))[1] * 0.90

      x = None
      for e in dev.read_loop():
          if e.type == evdev.ecodes.EV_ABS and e.code == evdev.ecodes.ABS_X:
              x = e.value
          elif e.type == evdev.ecodes.EV_KEY \
               and e.code == evdev.ecodes.BTN_TOUCH \
               and e.value == 1:
              if x and x > WIDTH:
                  subprocess.run(['xdotool', 'key', 'ctrl+d'])
    '';
    executable = true;
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
  home.stateVersion = "25.11";
}
