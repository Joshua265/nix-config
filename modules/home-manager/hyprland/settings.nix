{
  config,
  pkgs,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    /usr/lib/polkit-kde-authentication-agent-1 &
    ${pkgs.waybar}/bin/waybar &
    ${pkgs.swww}/bin/swww init &
    waypaper-engine daemon &
    ${pkgs.dunst}/bin/dunst init &
    nm-applet --indicator &
    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store
    sleep 1

  '';
  # ${pkgs.swww}/bin/swww img ${./wallpaper.png} &
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

  decoration = {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    rounding = 10;

    blur = {
      enabled = true;
      size = 3;
      passes = 1;
      vibrancy = 0.1696;
    };

    drop_shadow = true;
    shadow_range = 4;
    shadow_render_power = 3;
    "col.shadow" = "rgba(1a1a1aee)";
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

  master = {
    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    new_is_master = true;
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
    "HDMI-A-3, 2560x1440@60, 5120x0, 1, transform, 3"
    "DP-2, 5120x1440@120, 0x0, 1"
  ];

  workspace = [
    "1, monitor:DP-2"
    "2, monitor:DP-2"
    "3, monitor:DP-2"
    "4, monitor:DP-2"
    "5, monitor:DP-2"
    "6, monitor:DP-2"
    "7, monitor:DP-2"
    "8, monitor:DP-2"
    "9, monitor:DP-2"
    "10, monitor:HDMI-A-3"
  ];

  exec-once = ''${startupScript}/bin/start'';
}
