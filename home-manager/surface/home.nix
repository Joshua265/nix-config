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

  programs.gnome = {
    enable = true;
    # enable Accessibility → on-screen keyboard
    extraSettings = {
      "/org/gnome/desktop/a11y/applications/screen-keyboard-enabled" = true;
    };
  };

  # Ensure GDM’s greeter also has the on-screen keyboard turned on
  # by adding a small systemd service that writes the dconf key as the gdm user
  systemd.user.services.gdm-onboard = {
    description = "Enable GNOME on-screen keyboard for GDM";
    after = ["graphical-session.target"];
    serviceConfig = {
      User = "gdm";
      ExecStart = "${pkgs.dconf}/bin/dconf write /org/gnome/desktop/a11y/applications/screen-keyboard-enabled true";
      Type = "oneshot";
    };
    wantedBy = ["default.target"];
  };

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

  home.file."${touchScript}".text = ''
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
  # Make it executable
  home.file."${touchScript}".mode = "0755";
}
