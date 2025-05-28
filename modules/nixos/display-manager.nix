{
  pkgs,
  config,
  ...
}: let
  palette = config.home-manager.users.${config.main-user.userName}.colorScheme.palette;
  foreground = "#${palette.base05}";
  background = "#${palette.base00}";
  bordercolor = "#${palette.base02}";
  highlight = "#${palette.base04}";
in {
  # Enable Display Manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
            ${pkgs.greetd.tuigreet}/bin/tuigreet --remember --remember-session --remember-user-session --time --time-format '%I:%M %p | %a • %h | %F' --cmd "${pkgs.hyprland}/bin/Hyprland"
          --theme border=#${bordercolor};text=#${foreground};prompt=${highlight};time=#${highlight};action=#${highlight};button=#${foreground};container=#${background};input=${foreground}";
        '';
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    greetd.tuigreet
    greetd.regreet
    libsecret
  ];
}
