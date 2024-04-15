{
  config,
  pkgs,
  ...
}: let
  bg = "rgba(4, 20, 45, 0.50)";
  bg-alt = "#252428";
  fg = " #f5f5f5";
  alert = "#f53c3c";
  disabled = "#a5a5a5";
  bordercolor = "#29c8e5";
  highlight = "#FBD47F";
  activegreen = "#8fb666";
in {
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "loginctl lock-session";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "logout";
        action = "sleep 1; hyprctl dispatch exit";
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
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
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
        background-color: ${bg};
      }

      button {
      border-radius: 0;
      border-color: ${bordercolor};
      text-decoration-color: #FFFFFF;
        color: ${fg};
      background-color: ${highlight};
      border-style: solid;
      border-width: 1px;
      background-repeat: no-repeat;
      background-position: center;
      background-size: 25%;
      }

      button:focus, button:active, button:hover {
      	background-color: ${bg-alt};
      	outline-style: none;
      }

      #lock {
          background-image: image(url("./lock.svg"), url("/usr/local/share/wlogout/icons/lock.svg"));
      }

      #logout {
          background-image: image(url("./logout.svg"), url("/usr/local/share/wlogout/icons/logout.svg"));
      }

      #suspend {
          background-image: image(url("./suspend.svg"), url("/usr/local/share/wlogout/icons/suspend.svg"));
      }

      #hibernate {
          background-image: image(url("./hibernate.svg"), url("/usr/local/share/wlogout/icons/hibernate.svg"));
      }

      #shutdown {
          background-image: image(url("./shutdown.svg"), url("/usr/local/share/wlogout/icons/shutdown.svg"));
      }

      #reboot {
          background-image: image(url("./reboot.svg"), url("/usr/local/share/wlogout/icons/reboot.svg"));
      }
    '';
  };
}
