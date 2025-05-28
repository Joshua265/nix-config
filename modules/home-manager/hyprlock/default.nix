{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    wayland-protocols
  ];

  home.file.".config/hypr/wallpaper.jpg".source = ./wallpaper/hatsune-miku-anime-girl-4k-54.jpg;

  programs.hyprlock = {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.system}.hyprlock;

    settings = {
      background = [
        {
          monitor = null; # empty means all monitors
          path = "$HOME/.config/hypr/wallpaper.jpg";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      general = {
        disable_loading_bar = true;
        grace = 300;
        hide_cursor = true;
        no_fade_in = false;
      };

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "<i><span foreground=\"#cdd6f4\">Input Password...</span></i>";
          shadow_passes = 2;
        }
      ];

      auth = {
        pam.enabled = true;
        fingerprint.enabled = true;
      };

      label = [
        {
          monitor = null;
          text = "cmd[update:1000] echo \"$(date +\"%-I:%M%p\")\"";
          color = "$foreground";
          font_size = 120;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "[0 -300]";
          halign = "center";
          valign = "top";
        }
        {
          monitor = null;
          text = "Hi there, $USER";
          color = "$foreground";
          font_size = 25;
          font_family = "JetBrains Mono Nerd Font Mono";
          position = "[0 -40]";
          halign = "center";
          valign = "center";
        }
        {
          monitor = null;
          text = "cmd[update:1000] echo \"$(playerctl metadata --format '{{title}}  {{artist}}')\"";
          color = "$foreground";
          font_size = 18;
          font_family = "JetBrainsMono, Font Awesome 6 Free Solid";
          position = "[0 -50]";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
