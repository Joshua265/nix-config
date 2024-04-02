{
  config,
  pkgs,
  lib,
  ...
}: let
  style = import ./styles.nix;
  getKeyboardLayoutScript = pkgs.writeScriptBin "get_keyboard_layout.sh" ''
    #!${pkgs.bash}/bin/bash
    layout=$(hyprctl active | grep -oP 'Layout: \K\w+')
    echo $layout
  '';
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
        modules-left = ["hyprland/workspaces"];
        modules-right = [
          "custom/keyboard_layout"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
          "clock"
          "tray"
          "custom/wlogout"
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
        "hyprland/workspaces" = {
          format = "{icon}";
          "on-scroll-up" = "hyprctl dispatch workspace e+1";
          "on-scroll-down" = "hyprctl dispatch workspace e-1";
        };
        "custom/keyboard_layout" = {
          exec = "${getKeyboardLayoutScript}";
          interval = 5;
          format = "Layout: {}";
        };
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
          on-click = "wlogout";
        };
      }
    ];
  };
}
