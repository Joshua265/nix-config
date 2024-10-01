{pkgs, ...}: let
  auto-rotate = pkgs.writeScriptBin "auto-rotate" ''
      #!/usr/bin/env bash

    # Get the name of your display
    DISPLAY_NAME=$(wlr-randr | grep '^\*' | awk '{print $2}')

    # Listen for orientation changes
    monitor-sensor | while read -r line; do
      if echo "$line" | grep -q "orientation changed"; then
        ORIENTATION=$(echo "$line" | awk '{print $NF}')
        case "$ORIENTATION" in
          normal)
            hyprctl dispatch dpms on "$DISPLAY_NAME"
            hyprctl keyword monitor "$DISPLAY_NAME,preferred,0x0,1"
            ;;
          left-up)
            hyprctl dispatch dpms on "$DISPLAY_NAME"
            hyprctl keyword monitor "$DISPLAY_NAME,preferred,0x0,3"
            ;;
          bottom-up)
            hyprctl dispatch dpms on "$DISPLAY_NAME"
            hyprctl keyword monitor "$DISPLAY_NAME,preferred,0x0,2"
            ;;
          right-up)
            hyprctl dispatch dpms on "$DISPLAY_NAME"
            hyprctl keyword monitor "$DISPLAY_NAME,preferred,0x0,4"
            ;;
        esac
      fi
    done
  '';
in {
  environment.systemPackages = [auto-rotate];
}
