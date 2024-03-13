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
      background-color: ${bg-alt};
      border-style: solid;
      border-width: 1px;
      background-repeat: no-repeat;
      background-position: center;
      background-size: 25%;
      }

      button:focus, button:active, button:hover {
      	background-color: #3700B3;
      	outline-style: none;
      }

      #lock {
          background-image: image(url("/usr/share/wlogout/icons/lock.png"), url("/usr/local/share/wlogout/icons/lock.png"));
      }

      #logout {
          background-image: image(url("/usr/share/wlogout/icons/logout.png"), url("/usr/local/share/wlogout/icons/logout.png"));
      }

      #suspend {
          background-image: image(url("/usr/share/wlogout/icons/suspend.png"), url("/usr/local/share/wlogout/icons/suspend.png"));
      }

      #hibernate {
          background-image: image(url("/usr/share/wlogout/icons/hibernate.png"), url("/usr/local/share/wlogout/icons/hibernate.png"));
      }

      #shutdown {
          background-image: image(url("/usr/share/wlogout/icons/shutdown.png"), url("/usr/local/share/wlogout/icons/shutdown.png"));
      }

      #reboot {
          background-image: image(url("/usr/share/wlogout/icons/reboot.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
      }
    '';
  };
}
