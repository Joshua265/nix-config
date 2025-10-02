{...}: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on"; # avoid double keypress after resume
        inhibit_sleep = 3; # wait until the lock screen is active before sleeping
      };

      listener = [
        # Soften backlight first
        {
          timeout = 150;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }

        # Optional: keyboard backlight if present
        {
          timeout = 150;
          on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0";
          on-resume = "brightnessctl -rd rgb:kbd_backlight";
        }

        # Lock, then blank
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
        }

        # Finally, sleep (pair with suspend-then-hibernate below)
        {
          timeout = 1800;
          on-timeout = "systemctl suspend-then-hibernate";
        }

        # Events (keep yours)
        {
          event = "lid_close";
          on-event = "loginctl lock-session";
        }
        {
          event = "power_button";
          on-event = "loginctl lock-session";
        }
        {
          event = "before_sleep";
          on-event = "loginctl lock-session";
        }
      ];
    };
  };
}
