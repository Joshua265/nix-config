{
  config,
  pkgs,
  lib,
  ...
}: let
  style = import ./styles.nix;
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    inherit style;
    settings = [
      {
        height = 30;
        layer = "top";
        position = "top";
        tray = {spacing = 10;};
        modules-center = ["hyprland/window"];
        modules-left = ["hyperland/workspaces"];
        "hyprland/workspaces" = {
          on-click = "activate";
          active-only = false;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "6" = "";
            "7" = "";
            "8" = "";
            "9" = "󰙯";
            "10" = "";
            # "urgent": "",
            # "active": "",
            # "default": ""
          };
        };
        modules-right =
          [
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
          ]
          ++ [
            "clock"
            "tray"
          ];
        # battery = {
        #   format = "{capacity}% {icon}";
        #   format-alt = "{time} {icon}";
        #   format-charging = "{capacity}% ";
        #   format-icons = ["" "" "" "" ""];
        #   format-plugged = "{capacity}% ";
        #   states = {
        #     critical = 15;
        #     warning = 30;
        #   };
        # };
        clock = {
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "{:%Y-%m-%d | %H:%M}";
        };
        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };
        memory = {format = "{}% ";};
        network = {
          interval = 1;
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          format-disconnected = "Disconnected ⚠";
          format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
          format-linked = "{ifname} (No IP) ";
          format-wifi = "{essid} ({signalStrength}%) ";
        };
        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-icons = {
            car = "";
            default = ["" "" ""];
            handsfree = "";
            headphones = "";
            headset = "";
            phone = "";
            portable = "";
          };
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          on-click = "pavucontrol";
        };

        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = ["" "" ""];
        };
        "custom/wlogout" = {
          format = "";
          interval = "once";
          on-click = "wlogout -c 5 -r 5 -p layer-shell";
        };
      }
    ];
  };
}
