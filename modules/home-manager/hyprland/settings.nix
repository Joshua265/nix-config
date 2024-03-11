{
  config,
  pkgs,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/waybar &
    ${pkgs.swww}/bin/swww init &
    ${pkgs.dunst}/bin/dunst init &
    nm-applet --indicator &
    sleep 1

  '';
  # ${pkgs.swww}/bin/swww img ${./wallpaper.png} &
in {
  "$mod" = "SUPER";
  bind =
    [
      "$mod, F, exec, firefox"
      ", Print, exec, grimblast copy area"
      "$mod, space, exec, rofi -show drun -show-icons" # rofi
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
  exec-once = ''${startupScript}/bin/start'';
}
