{
  config,
  pkgs,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    killall -q waybar &
    systemctl --user start plasma-polkit-agent
    hyprctl setcursor catppuccin-frappe-blue-cursors 24
    gsettings set org.gnome.desktop.interface cursor-theme catppuccin-frappe-blue-cursor
    ${pkgs.swww}/bin/swww init &
    # ${pkgs.eww}/bin/eww deamon &
    ${pkgs.waybar}/bin/waybar &
    swayidle -w timeout 300 'swaylock -f -c 000000' \
            timeout 600 'systemctl suspend' \
            before-sleep 'swaylock -f -c 000000' &
    sleep 1
    ${pkgs.swww}/bin/swww img ${./wallpaper/anime-girl-in-scifi-world-5k-pk-5120x2880.jpg} &
    # ${pkgs.eww}/bin/eww open bar &
    ${pkgs.mako}/bin/mako init &
    nm-applet --indicator &
    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &
  '';
  gameModeScript = pkgs.pkgs.writeShellScriptBin "gameModeScript" ''
    HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
    if [ "$HYPRGAMEMODE" = 1 ] ; then
        hyprctl --batch "\
            keyword animations:enabled 0;\
            keyword decoration:drop_shadow 0;\
            keyword decoration:blur:enabled 0;\
            keyword general:gaps_in 0;\
            keyword general:gaps_out 0;\
            keyword general:border_size 1;\
            keyword decoration:rounding 0"
        exit
    fi
    hyprctl reload
  '';
in {
  general = {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    gaps_in = 5;
    gaps_out = 20;
    border_size = 2;
    "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
    "col.inactive_border" = "rgba(595959aa)";

    layout = "dwindle";

    # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false;
  };

  input = {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    follow_mouse = 1;
    numlock_by_default = true;
    kb_layout = "us,de";
    kb_options = "grp:alt_shift_toggle";
  };

  device = {
    name = "ugee-21.5-inch-pendisplay-stylus";
    output = "HDMI-A-3";
  };

  decoration = {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    rounding = 8;
    inactive_opacity = 0.8;
    active_opacity = 0.9;

    blur = {
      enabled = true;
      size = 8;
      passes = 1;
    };

    drop_shadow = true;
    shadow_range = 4;
    shadow_render_power = 3;
    "col.shadow" = "rgba(1a1a1aee)";
  };

  misc = {
    disable_hyprland_logo = true; # we have swww for that
    focus_on_activate = true; # focus on window when it's activated
  };

  animations = {
    enabled = true;
    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
    bezier = ["myBezier, 0.05, 0.9, 0.1, 1.05"];

    animation = [
      "windows, 1, 7, myBezier"
      "windowsOut, 1, 7, default, popin 80%"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 7, default"
      "workspaces, 1, 6, default"
    ];
  };
  dwindle = {
    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true; # you probably want this
  };

  gestures = {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    workspace_swipe = false;
  };

  # windowrulev2 = ["suppressevent maximize, class:.*"]; # You'll probably like this. # error

  # Set programs that you use
  "$terminal" = "kitty";
  "$fileManager" = "dolphin";
  "$menu" = "rofi --show drun";

  "$mod" = "SUPER";
  bind =
    [
      "$mod, F, exec, firefox"
      ", Print, exec, grimblast copy area"
      "$mod, space, exec, rofi -show drun -show-icons || rofi" # rofi
      "$mod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy" # clipboard history
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
      "$mod, Q, exec, $terminal"
      "$mod, W, killactive,"
      "$mod, E, exec, $fileManager"
      "$mod, T, togglefloating,"
      "$mod, L, exec, swaylock -f -c 000000"
      ''$mod, F10, exec, ${gameModeScript}/bin/gameModeScript''
      '', Print, exec, filename="$HOME/Pictures/$(date +%Y-%m-%d-%H%M%S).png"; grim -g "$(slurp -d)" "$filename" && wl-copy < "$filename"''
      ''$mod, s, exec, filename="$HOME/Pictures/$(date +%Y-%m-%d-%H%M%S).png"; grim -g "$(slurp -d)" "$filename" && wl-copy < "$filename"''
      '', XF86AudioRaiseVolume, exec, pamixer -i 5''
      '', XF86AudioLowerVolume, exec, pamixer -d 5 ''
      '', XF86AudioMicMute, exec, pamixer --default-source -m''
      '', XF86AudioMute, exec, pamixer -t''
      '', XF86AudioPlay, exec, playerctl play-pause''
      '', XF86AudioPause, exec, playerctl play-pause''
      '', XF86AudioNext, exec, playerctl next''
      '', XF86AudioPrev, exec, playerctl previous''
    ]
    ++ (
      # workspaces
      # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
      builtins.concatLists (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in [
            "$mod, ${ws}, workspace, ${toString (x + 1)}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
          ]
        )
        10)
    );
  bindm = [
    "$mod,mouse:272,movewindow"
    "$mod,mouse:273,resizewindow"
  ];

  bindel = [
    ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
    ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
  ];
  bindl = ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

  monitor = [
    "HDMI-A-3, 1920x1080@60, 0x1440, 1"
    # "HDMI-A-4, 2560x1440@60, 5120x0, 1, transform, 3"
    "DP-3, 5120x1440@120, 0x0, 1"
    # "DP-3, addreserved, 0, 0, 52, 0" # for eww sidebar
  ];

  workspace = [
    "1, monitor:DP-3"
    "2, monitor:DP-3"
    "3, monitor:DP-3"
    "4, monitor:DP-3"
    "5, monitor:DP-3"
    "6, monitor:DP-3"
    "7, monitor:DP-3"
    "8, monitor:DP-3"
    # "9, monitor:HDMI-A-4"
    "10, monitor:HDMI-A-3"
  ];

  exec-once = ''${startupScript}/bin/start'';
}
