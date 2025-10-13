{
  config,
  pkgs,
  nix-colors,
  lib,
  ...
}: let
  style = import ./styles.nix {inherit nix-colors config;};

  getKeyboardLayoutScript = pkgs.writeScriptBin "getKeyboardLayout" ''
    #!${pkgs.bash}/bin/bash
    layout=$(hyprctl devices -j | jq '.keyboards[] | select(.name == "${config.waybar.keyboard-name}") | .active_keymap')
    'echo ''${layout//\"}'
  '';
in {
  options = {
    waybar = {
      keyboard-name = lib.mkOption {
        description = "The name of the keyboard to get the layout from";
        type = lib.types.str;
      };
    };
  };
  config = {
    home.packages = [
      pkgs.playerctl
      pkgs.coppwr
      pkgs.pavucontrol
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
          tray = {
            spacing = 10;
            icon-size = 20;
          };
          modules-center = ["cpu" "memory" "temperature" "battery"];
          modules-left = ["custom/launcher" "hyprland/workspaces" "custom/playerctl" "custom/playerlabel"];
          modules-right = [
            "tray"
            "custom/keyboard_layout"
            "pulseaudio"
            # "custom/pipewire"
            "backlight"
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
            format-charging = "{capacity}% ";
            format-icons = ["" "" "" "" ""];
            format-plugged = "{capacity}% ";
            states = {
              critical = 5;
              warning = 15;
            };
            "events" = {
              "on-discharging-warning" = "notify-send -u normal 'Low Battery'";
              "on-discharging-critical" = "notify-send -u critical 'Very Low Battery'";
              "on-charging-100" = "notify-send -u normal 'Battery Full!'";
            };
          };
          "hyprland/workspaces" = {
            format = "{icon}";
            "format-icons" = {
              "urgent" = "";
              "active" = "";
              "visible" = "";
              "default" = "";
              "empty" = "";
            };
            "all-outputs" = false;
          };
          "custom/keyboard_layout" = {
            exec = "${getKeyboardLayoutScript}/bin/getKeyboardLayout";
            interval = 5;
            format = " {}";
          };
          clock = {
            interval = 1;
            "format" = "  {:%H:%M:%S}";
            "tooltip" = "true";
            "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            "format-alt" = " {:%d/%m/%y}";
          };
          cpu = {
            format = " {usage}%";
            "format-alt" = " {avg_frequency} GHz";
            interval = 5;
          };
          memory = {
            format = "{}%";
            "format-alt" = " {used}/{total} GiB";
            "interval" = 5;
          };
          network = {
            format-wifi = "󰤨 {essid}";
            format-ethernet = "󰈀 {ifname}";
            format-linked = " {ifname} (No IP)";
            format-disconnected = "󰤭";
            "format-alt" = "󰩠 {ifname}: {ipaddr}/{cidr}";
            tooltip-format = "{essid}";
            on-click-right = "nm-connection-editor";
          };
          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = "󰝟 {format_source}";
            format-icons = {
              car = "";
              default = ["" "" ""];
              handsfree = "";
              headphones = "";
              headset = "󰋎";
              phone = "";
              portable = "";
            };
            format-muted = "󰝟 {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            on-click = "pavucontrol";
          };
          # "custom/pipewire" = {
          #   "format" = "{icon}";
          #   "return-type" = "json";
          #   "signal" = 8;
          #   "interval" = "once";
          #   "format-icons" = {
          #     "mute" = "";
          #     "default" = ["" "" "" ""];
          #   };
          #   "exec" = "pw-volume status";
          #   on-click = "";
          # };
          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = ["" "" ""];
          };
          "custom/wlogout" = {
            format = " ⏻ ";
            tooltip = false;
            on-click = "wlogout --protocol layer-shell";
          };
          # "custom/playerctl" = {
          #   format = "{icon}";
          #   return-type = "json";
          #   max-length = 64;
          #   exec = "${playerctl}/bin/playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          #   on-click-middle = "${playerctl}/bin/playerctl play-pause";
          #   on-click = "${playerctl}/bin/playerctl previous";
          #   on-click-right = "${playerctl}/bin/playerctl next";
          #   format-icons = {
          #     Playing = "<span foreground='#E5B9C6'>󰒮 󰐌 󰒭</span>";
          #     Paused = "<span foreground='#928374'>󰒮 󰏥 󰒭</span>";
          #   };
          # };
          # "custom/playerlabel" = {
          #   format = "<span>{}</span>";
          #   return-type = "json";
          #   max-length = 48;
          #   exec = "${playerctl}/bin/playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          #   on-click-middle = "${playerctl}/bin/playerctl play-pause";
          #   on-click = "${playerctl}/bin/playerctl previous";
          #   on-click-right = "${playerctl}/bin/playerctl next";
          #   format-icons = {
          #     Playing = "<span foreground='#E5B9C6'>󰒮 󰐌 󰒭</span>";
          #     Paused = "<span foreground='#928374'>󰒮 󰏥 󰒭</span>";
          #   };
          # };
          "custom/launcher" = {
            format = "󱤅";
            on-click = "rofi -show drun -show-icons || rofi";
          };
        }
      ];
    };
  };
}
