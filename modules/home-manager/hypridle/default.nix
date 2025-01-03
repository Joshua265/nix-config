{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.hypridle.packages.${pkgs.system}.hypridle
  ];

  home.file.".config/hypridle/config.toml" = {
    text = ''
      general {
          lock_cmd = pidof hyprlock || hyprlock       # avoid starting multiple hyprlock instances.
          before_sleep_cmd = loginctl lock-session    # lock before suspend.
          after_sleep_cmd = hyprctl dispatch dpms on  # to avoid having to press a key twice to turn on the display.
      }

      listener {
          timeout = 150                                # 2.5min.
          on-timeout = brightnessctl -s set 10         # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = brightnessctl -r                 # monitor backlight restore.
      }

      # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
      listener {
          timeout = 150                                          # 2.5min.
          on-timeout = brightnessctl -sd rgb:kbd_backlight set 0 # turn off keyboard backlight.
          on-resume = brightnessctl -rd rgb:kbd_backlight        # turn on keyboard backlight.
      }

      listener {
          timeout = 300                                 # 5min
          on-timeout = loginctl lock-session            # lock screen when timeout has passed
      }

      listener {
          timeout = 330                                 # 5.5min
          on-timeout = hyprctl dispatch dpms off        # screen off when timeout has passed
          on-resume = hyprctl dispatch dpms on          # screen on when activity is detected after timeout has fired.
      }

      listener {
          timeout = 1800                                # 30min
          on-timeout = systemctl suspend                # suspend pc
      }

      # Lock screen on lid close and power button press
      listener {
          event = lid_close                             # Event for lid close
          on-event = loginctl lock-session              # Lock screen on lid close
      }

      listener {
          event = power_button                          # Event for power button press
          on-event = loginctl lock-session              # Lock screen on power button
      }

      # Optionally, lock screen before sleep
      listener {
          event = before_sleep                          # Event before system sleep
          on-event = loginctl lock-session              # Lock screen before sleep
      }
    '';
  };
}
