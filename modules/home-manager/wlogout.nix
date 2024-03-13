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
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
    ];
    style = ''
      window {
        background: ${bg};
      }

      button {
        color: ${fg};
      }
    '';
  };
}
