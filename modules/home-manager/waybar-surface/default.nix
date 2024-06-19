{
  config,
  pkgs,
  lib,
  ...
}: let
  style = import ./styles.nix;
  getKeyboardLayoutScript = pkgs.writeScriptBin "getKeyboardLayout" ''
    #!${pkgs.bash}/bin/bash
    layout=$(hyprctl devices -j | jq '.keyboards[] | select(.name == "microsoft-surface-type-cover-keyboard") | .active_keymap')
    echo $layout
  '';
  brightnessScript = pkgs.writeScriptBin "brightness" ''
    #!${pkgs.bash}/bin/bash

    case "$1" in
        "get")
            brightnessctl g | awk '{print int($1*100/7500)}'
            ;;
        "set")
            brightnessctl s $2%
            ;;
        *)
            current_brightness=$(brightnessctl g | awk '{print int($1*100/7500)}')
            echo "$current_brightness"
            ;;
    esac
  '';
in {
  home.packages = with pkgs; [
    jq
    brightnessctl
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = false; # start with hyprland
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
          "backlight"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
          "battery"
          "clock"
          "tray"
          "custom/wlogout"
        ];
        battery = {
          format = "{capacity}% {icon}";
          format-alt = "{time} {icon}";
          format-charging = "{capacity}% ";
          format-icons = ["" "" "" "" ""];
          format-plugged = "{capacity}% ";
          states = {
            critical = 15;
            warning = 30;
          };
        };
        "hyprland/workspaces" = {
          format = "{icon}";
          "on-scroll-up" = "hyprctl dispatch workspace e+1";
          "on-scroll-down" = "hyprctl dispatch workspace e-1";
        };
        "custom/keyboard_layout" = {
          exec = "${getKeyboardLayoutScript}/bin/getKeyboardLayout";
          interval = 5;
          format = " {}";
        };
        backlight = {
          device = "intel_backlight";
          format = "{percent}% {icon}";
          format-icons = ["" ""];
        };
        # "custom/brightness" = {
        #   format = "{value}%";
        #   interval = 5;
        #   exec = "${brightnessScript}/bin/brightnessScript get";
        #   tooltip = false;
        #   "exec-if" = "type brightnessctl";
        #   "on-click" = "${brightnessScript}/bin/brightnessScript set 50"; # Example for setting brightness to 50%
        #   "on-scroll-up" = "${brightnessScript}/bin/brightnessScript set $(($( ${brightnessScript}/bin/brightnessScript get) + 5))";
        #   "on-scroll-down" = "${brightnessScript}/bin/brightnessScript set $(($( ${brightnessScript}/bin/brightnessScript get) - 5))";
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
          format = " ⏻ ";
          tooltip = false;
          on-click = "wlogout --protocol layer-shell";
        };
      }
    ];
  };
}
