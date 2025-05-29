{...}: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 900;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 930;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
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
