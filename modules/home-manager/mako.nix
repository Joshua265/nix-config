{
  config,
  nix-colors,
  ...
}: let
  palette = config.colorScheme.palette;

  # hex → [r g b]
  hexToRGB = hex: nix-colors.lib.conversions.hexToRGB hex;

  # hex + alpha → "rgba(r, g, b, a)" string
  hexToRGBA = hex: alpha: let
    rgb = hexToRGB hex;
    r = toString (builtins.elemAt rgb 0);
    g = toString (builtins.elemAt rgb 1);
    b = toString (builtins.elemAt rgb 2);
    a = toString alpha;
  in "rgba(${r}, ${g}, ${b}, ${a})";

  # Glassy / style definitions
  mako_bg = hexToRGBA palette.base01 0.85;
  mako_border = hexToRGBA palette.base00 1.0;
  mako_text = "#${palette.base05}";
  mako_low_bg = hexToRGBA palette.base02 0.9;
  mako_normal_bg = hexToRGBA palette.base08 0.9;
  mako_urgent_bg = hexToRGBA palette.base09 0.9;
in {
  services.mako = {
    enable = true;

    # Use settings instead of extraConfig
    settings = {
      margin = 8;
      gap = 6;
      anchor = "bottom-right";
      width = 320;

      background = mako_bg;
      border = 1;
      border_color = mako_border;
      radius = 12;

      font = "Iosevka 12";
      text_color = mako_text;

      # Mode “low urgency”
      "urgency_low" = {
        background = mako_low_bg;
        border_color = mako_border;
      };

      # Mode “normal urgency”
      "urgency_normal" = {
        background = mako_normal_bg;
        border_color = mako_border;
      };

      # Mode “critical / urgent”
      "urgency_critical" = {
        background = mako_urgent_bg;
        border_color = mako_border;
      };

      # Position in layers: background | bottom | top | overlay
      # Use “top” or “overlay” so notifications draw above windows
      layer = "top";
    };
  };
}
