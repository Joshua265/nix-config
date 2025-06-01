{
  inputs,
  config,
  pkgs,
  nix-colors,
  ...
}: let
  hexToRGBString = hex: let
    rgb = nix-colors.lib.conversions.hexToRGB hex;
    r = toString (builtins.elemAt rgb 0);
    g = toString (builtins.elemAt rgb 1);
    b = toString (builtins.elemAt rgb 2);
  in "rgb(${r}, ${g}, ${b})";
  palette = config.colorScheme.palette;
  foreground = hexToRGBString (palette.base05);
  background = hexToRGBString (palette.base00);
in {
  home.packages = with pkgs; [
    wayland-protocols
  ];

  home.file.".config/hypr/wallpaper.jpg".source = ./wallpaper/hatsune-miku-anime-girl-4k-54.jpg;

  programs.hyprlock = {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.system}.hyprlock;

    settings = {
      general = {
        hide_cursor = false;
      };

      background = {
        monitor = "";
        path = "$HOME/.config/hypr/wallpaper.jpg";
        color = background;
      };

      input-field = {
        size = "200, 50";
        position = "0, -120";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        font_color = foreground;
        inner_color = background;
        outer_color = "rgb(24, 25, 38)";
        outline_thickness = 5;
        shadow_passes = 2;
      };

      auth = {
        pam.enabled = true;
        fingerprint.enabled = true;
      };

      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%-I:%M%p\")\"";
          color = foreground;
          font_size = 80;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "0 ,-300";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "Hi there, $USER";
          color = foreground;
          font_size = 25;
          font_family = "JetBrains Mono Nerd Font Mono";
          position = "0 ,-40";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(playerctl metadata --format '{{title}}  {{artist}}')"'';
          color = foreground;
          font_size = 18;
          font_family = "JetBrainsMono, Font Awesome 6 Free Solid";
          position = "0 ,-50";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
