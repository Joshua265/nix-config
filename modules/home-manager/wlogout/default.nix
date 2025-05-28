{
  pkgs,
  config,
  ...
}: let
  foreground = "#${config.colorScheme.palette.base05}";
  background = "#${config.colorScheme.palette.base00}";
  bordercolor = "#${config.colorScheme.palette.base02}";
  highlight = "#${config.colorScheme.palette.base04}";
in {
  home.packages = with pkgs; [
    wleave # has nicer images that wlogout
  ];
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "logout";
        action = "hyprctl dispatch exit";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];

    style = ''
      * {
        background-image: none;
        box-shadow: none;
      }

      window {
        background-color: ${background};
      }

      button {
        border-radius: 0;
        border-color: black;
        text-decoration-color: ${highlight};
        color: ${foreground};
        background-color: ${background};
        border-color: ${bordercolor};
        border-style: solid;
        border-width: 1px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
      }

      button:focus, button:active, button:hover {
        outline-style: none;
        background-color: ${highlight};
      }

      #lock {
        background-image: image(url("${pkgs.wleave}/share/wleave/icons/lock.svg"));
      }

      #logout {
        background-image: image(url("${pkgs.wleave}/share/wleave/icons/logout.svg"));
      }

      #shutdown {
        background-image: image(url("${pkgs.wleave}/share/wleave/icons/shutdown.svg"));
      }

      #reboot {
        background-image: image(url("${pkgs.wleave}/share/wleave/icons/reboot.svg"));
      }
    '';
  };
}
