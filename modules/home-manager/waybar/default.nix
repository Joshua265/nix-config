{
  config,
  pkgs,
  lib,
  ...
}: let
  style = import ./styles.nix;
  getKeyboardLayoutScript = pkgs.writeScriptBin "getKeyboardLayout" ''
    #!${pkgs.bash}/bin/bash
    layout=$(hyprctl devices -j | jq '.keyboards[] | select(.name == "razer-razer-ornata-chroma") | .active_keymap')
    echo $layout
  '';
  playerctl = pkgs.writeScriptBin "playerctl" ''
        #!/bin/bash

    playerctl_status=$(playerctl status 2>/dev/null)

    if [[ $playerctl_status == "Playing" ]]; then
        title=$(playerctl metadata title 2>/dev/null)
        echo '{"text":"󰎈 󰏤","class":"playing","title":"$title"}'
    elif [[ $playerctl_status == "Paused" ]]; then
        title=$(playerctl metadata title 2>/dev/null)
        echo '{"text":"󰎈 󰐊","class":"paused","title":"$title"}'
    else
        echo '{"text":""}'
    fi
  '';
in {
  programs.waybar = {
    enable = true;
    systemd.enable = false; # start with hyprland
    inherit style;
    settings = [
      {
        height = 30;
        layer = "top";
        position = "top";
        tray = {
          spacing = 10;
          icon-size = 20;
        };
        modules-center = ["cpu" "memory" "temperature"];
        modules-left = ["custom/launcher" "hyprland/workspaces" "custom/playerctl" "custom/playerlabel"];
        modules-right = [
          "tray"
          "custom/keyboard_layout"
          "pulseaudio"
          "network"
          "custom/wlogout"
          "clock"
        ];
        backlight = {
          device = "intel_backlight";
          format = "{percent}% {icon}";
          format-icons = ["" ""];
        };
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
        "clock" = {
          "format" = " {:%H:%M}";
          "tooltip" = "true";
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          "format-alt" = " {:%d/%m}";
        };
        cpu = {
          format = "󰻠 {usage}%";
          "format-alt" = "󰻠 {avg_frequency} GHz";
          interval = 5;
        };
        memory = {
          format = "{}% ";
          "format-alt" = "󰍛 {used}/{total} GiB";
          "interval" = 5;
        };
        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = " {ifname}";
          format-linked = " {ifname} (No IP)";
          format-disconnected = "󰤭";
          "format-alt" = " {ifname}: {ipaddr}/{cidr}";
          tooltip-format = "{essid}";
          on-click-right = "nm-connection-editor";
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
        "custom/playerctl" = {
          format = "{icon}";
          return-type = "json";
          max-length = 64;
          exec = "${playerctl}/bin/playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          on-click-middle = "${playerctl}/bin/playerctl play-pause";
          on-click = "${playerctl}/bin/playerctl previous";
          on-click-right = "${playerctl}/bin/playerctl next";
          format-icons = {
            Playing = "<span foreground='#E5B9C6'>󰒮 󰐌 󰒭</span>";
            Paused = "<span foreground='#928374'>󰒮 󰏥 󰒭</span>";
          };
        };
        "custom/playerlabel" = {
          format = "<span>{}</span>";
          return-type = "json";
          max-length = 48;
          exec = "${playerctl}/bin/playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          on-click-middle = "${playerctl}/bin/playerctl play-pause";
          on-click = "${playerctl}/bin/playerctl previous";
          on-click-right = "${playerctl}/bin/playerctl next";
          format-icons = {
            Playing = "<span foreground='#E5B9C6'>󰒮 󰐌 󰒭</span>";
            Paused = "<span foreground='#928374'>󰒮 󰏥 󰒭</span>";
          };
        };
        "custom/launcher" = {
          format = "󰈸";
          on-click = "rofi -show drun -show-icons || rofi";
        };
      }
    ];
  };
}
