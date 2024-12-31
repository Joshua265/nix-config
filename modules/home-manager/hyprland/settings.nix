{
  inputs,
  lib,
  pkgs,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    # killall -q waybar &
    systemctl --user start plasma-polkit-agent &
    ${pkgs.swww}/bin/swww init &
    ${pkgs.waybar}/bin/waybar &
    ${inputs.hypridle.packages.${pkgs.system}.hypridle}/bin/hypridle &
    sleep 1
    ${pkgs.swww}/bin/swww img ${./wallpaper/hhma415rpztb1.jpg} &
    ${pkgs.mako}/bin/mako init &
    nm-applet --indicator &
    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &
  '';
in {
  general = {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    gaps_in = 4;
    gaps_out = 5;
    border_size = 2;
    "col.active_border" = "rgba(471868FF)";
    "col.inactive_border" = "rgba(4f4256CC)";

    layout = "dwindle";

    # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false;
  };

  dwindle = {
    preserve_split = true;
    smart_resizing = false;
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
      xray = true;
      special = false;
      new_optimizations = true;
      size = 5;
      passes = 4;
      brightness = 1;
      noise = 1.0e-2;
      contrast = 1;
    };

    shadow = {
      enabled = true;
    };
  };

  windowrule = [
    "noblur,.*" # Disables blur for windows. Substantially improves performance.
    "float, ^(steam)$"
    "pin, ^(showmethekey-gtk)$"
    "float,title:^(Open File)(.*)$"
    "float,title:^(Select a File)(.*)$"
    "float,title:^(Choose wallpaper)(.*)$"
    "float,title:^(Open Folder)(.*)$"
    "float,title:^(Save As)(.*)$"
    "float,title:^(Library)(.*)$ "
  ];
  layerrule = [
    "xray 1, .*"
    "noanim, selection"
    "noanim, overview"
    "noanim, anyrun"
    "blur, swaylock"
    "blur, eww"
    "ignorealpha 0.8, eww"
    "noanim, noanim"
    "blur, noanim"
    "blur, gtk-layer-shell"
    "ignorezero, gtk-layer-shell"
    "blur, launcher"
    "ignorealpha 0.5, launcher"
    "blur, notifications"
    "ignorealpha 0.69, notifications"
    "blur, session"
    "noanim, sideright"
    "noanim, sideleft"
  ];

  misc = {
    vfr = 1;
    vrr = 1;
    # layers_hog_mouse_focus = true;
    focus_on_activate = true;
    animate_manual_resizes = false;
    animate_mouse_windowdragging = false;
    enable_swallow = false;
    swallow_regex = "(foot|kitty|allacritty|Alacritty)";

    disable_hyprland_logo = true;
    new_window_takes_over_fullscreen = 2;
  };

  animations = {
    enabled = true;
    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
    bezier = [
      "md3_decel, 0.05, 0.7, 0.1, 1"
      "md3_accel, 0.3, 0, 0.8, 0.15"
      "overshot, 0.05, 0.9, 0.1, 1.1"
      "crazyshot, 0.1, 1.5, 0.76, 0.92"
      "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
      "fluent_decel, 0.1, 1, 0, 1"
      "easeInOutCirc, 0.85, 0, 0.15, 1"
      "easeOutCirc, 0, 0.55, 0.45, 1"
      "easeOutExpo, 0.16, 1, 0.3, 1"
    ];

    animation = [
      "windows, 1, 3, md3_decel, popin 60%"
      "border, 1, 10, default"
      "fade, 1, 2.5, md3_decel"
      # "workspaces, 1, 3.5, md3_decel, slide"
      "workspaces, 1, 7, fluent_decel, slide"
      # "workspaces, 1, 7, fluent_decel, slidefade 15%"
      # "specialWorkspace, 1, 3, md3_decel, slidefadevert 15%"
      "specialWorkspace, 1, 3, md3_decel, slidevert"
    ];
  };

  gestures = {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    workspace_swipe = true;
    workspace_swipe_cancel_ratio = 0.15;
  };

  # windowrulev2 = ["suppressevent maximize, class:.*"]; # You'll probably like this. # error

  # Set programs that you use
  "$terminal" = "alacritty";
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
      '', Print, exec, filename="$HOME/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png"; grim -g "$(slurp -d)" "$filename" && wl-copy < "$filename"''
      ''$mod, s, exec, filename="$HOME/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png"; grim -g "$(slurp -d)" "$filename" && wl-copy < "$filename"''
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

  "plugin:touch_gestures" = {
    hyprgrass-bindm = [
      ", tap:3, exec, rofi -show drun -show-icons || rofi"
      ", longpress:2, movewindow"
      ", longpress:3, resizewindow"
    ];
  };

  xwayland = {
    force_zero_scaling = true;
  };

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
