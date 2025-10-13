{
  config,
  nix-colors,
}: let
  hexToRGB = hex: let
    rgb = nix-colors.lib.conversions.hexToRGB hex;
  in
    rgb;

  hexToRGBA = hex: alpha: let
    rgb = hexToRGB hex;
    r = toString (builtins.elemAt rgb 0);
    g = toString (builtins.elemAt rgb 1);
    b = toString (builtins.elemAt rgb 2);
    a = toString alpha;
  in "rgba(${r}, ${g}, ${b}, ${a})";
  palette = config.colorScheme.palette;

  background = "#${palette.base00}";
  bg_paper = "#${palette.base01}";
  foreground = "#${palette.base05}";
  accent = "#${palette.base0E}";
  accent_alt = "#${palette.base0B}";

  glass_bg = hexToRGBA palette.base01 0.55;
  glass_bg_soft = hexToRGBA palette.base01 0.38;
  glass_stroke = hexToRGBA palette.base07 0.14;
  glass_inner = hexToRGBA palette.base08 0.06;
  glass_shadow = hexToRGBA palette.base00 0.55;

  text_main = hexToRGBA palette.base05 1.0;
  text_muted = hexToRGBA palette.base07 0.65;

  acc_fg = hexToRGBA palette.base0E 1.0;
  acc_bg = hexToRGBA palette.base0E 0.18;
  acc_ring = hexToRGBA palette.base0E 0.35;

  ok_fg = hexToRGBA palette.base0B 1.0;
  warn_fg = hexToRGBA palette.base0A 1.0;
  danger_fg = hexToRGBA palette.base09 1.0;
  cyan_fg = hexToRGBA palette.base06 1.0;
  cyan_soft = hexToRGBA palette.base06 0.14;
in ''
  /* ==== Base reset ======================================================= */
  * {
    border: none;
    border-radius: 0;
    font-family: Iosevka, FontAwesome, Noto Sans CJK;
    font-size: 14px;
    font-style: normal;
    min-height: 0;
    transition: background-color 120ms ease, color 120ms ease, box-shadow 120ms ease, border-color 120ms ease;
  }

  /* Whole bar: let compositor blur show through */
  window#waybar {
    background: rgba(39, 28, 58, 0.20); /* base00 @ 20% as a faint veil */
    color: ${text_main};
    /* optional frame; comment if you prefer fully frameless */
    border-bottom: 1px solid ${glass_stroke};
    box-shadow: inset 0 1px 0 ${glass_inner};
  }

  /* ==== Reusable “glass chip” pattern ==================================== */
  #workspaces,
  #tray,
  #clock,
  #custom-date,
  #battery,
  #pulseaudio,
  #network,
  #backlight,
  #cpu,
  #memory,
  #disk,
  #temperature,
  #custom-hyprpicker,
  #custom-power,
  #custom-wlogout,
  #window,
  #language,
  #custom-wf-recorder {
    background: ${glass_bg};
    color: ${text_main};
    padding: 6px 10px;
    margin: 6px 6px;
    border-radius: 12px;
    border: 1px solid ${glass_stroke};
    box-shadow:
      inset 0 1px 0 ${glass_inner},
      0 4px 12px ${glass_shadow};
  }

  /* Slightly softer backdrop for some blocks to create hierarchy */
  #clock, #tray {
    background: ${glass_bg_soft};
  }

  /* ==== Workspaces ======================================================== */
  #workspaces {
    padding: 2px 6px;
  }

  #workspaces button {
    padding: 2px 2px;
    margin: 2px 3px;
    color: ${text_muted};
    border-radius: 10px;
    background: transparent;
    box-shadow: none;
  }

  #workspaces button:hover {
    color: ${text_main};
    background: ${cyan_soft};
    border: 1px solid ${glass_stroke};
  }

  #workspaces button.active {
    color: ${acc_fg};
    background: ${acc_bg};
    border: 1px solid ${acc_ring};
    box-shadow:
      inset 0 1px 0 ${glass_inner},
      0 2px 8px ${glass_shadow};
  }

  /* ==== Clock & Date ====================================================== */
  #clock {
    font-weight: 700;
    padding: 6px 14px;
    border-radius: 12px 12px 12px 12px;
    color: ${cyan_fg}; /* base06 pop */
  }

  #custom-date {
    color: ${acc_fg}; /* base0E */
  }

  /* ==== System indicators ================================================= */
  #battery {
    color: ${ok_fg};
  }

  #battery.charging {
    color: ${ok_fg};
    background: rgba(115, 168, 60, 0.10);
    border-color: rgba(115, 168, 60, 0.25);
  }

  #battery.warning:not(.charging) {
    color: #000;
    background: rgba(215, 109, 106, 0.85); /* danger */
    border-color: rgba(215, 109, 106, 0.95);
    border-radius: 10px;
  }

  #pulseaudio {
    color: ${text_main};
  }

  #pulseaudio:hover {
    background: ${cyan_soft};
    border-color: ${glass_stroke};
  }

  #pulseaudio.muted {
    color: ${text_muted};
    background: transparent;
    border-color: ${glass_stroke};
  }

  #network {
    color: ${text_main};
  }

  /* ==== Utility chips ===================================================== */
  #backlight,
  #cpu,
  #memory,
  #disk,
  #temperature,
  #custom-hyprpicker {
    font-weight: 700;
    padding: 4px 12px;
  }

  #custom-wf-recorder {
    color: ${acc_fg};
  }

  /* ==== Launcher / Power / Window title =================================== */
  #custom-launcher {
    color: ${acc_fg};
    font-size: 24px;
    padding: 0px;
    margin: 2px 2px;
    border-radius: 12px;
  }
  #custom-launcher:hover {
    background: ${acc_bg};
    border-color: ${acc_ring};
  }

  #custom-power {
    color: ${text_main};
    padding: 6px 12px;
  }

  #window {
    background: transparent;           /* let the title read on the bar */
    border: 1px solid ${glass_stroke};
    padding: 4px 14px;
    font-weight: 500;
    color: ${text_muted};
  }

  /* ==== Tray & Language =================================================== */
  #tray {
    padding: 4px 8px;
  }

  #language {
    background: ${glass_bg_soft};
    color: ${foreground};
    padding: 2px 8px;
    min-width: 16px;
  }

  /* ==== Micro-polish ====================================================== */
  #custom-randwall { color: ${text_main}; }

  /* Subtle hover lift for all chips */
  #workspaces:hover,
  #tray:hover,
  #clock:hover,
  #custom-date:hover,
  #battery:hover,
  #pulseaudio:hover,
  #network:hover,
  #backlight:hover,
  #cpu:hover,
  #memory:hover,
  #disk:hover,
  #custom-hyprpicker:hover,
  #custom-launcher:hover,
  #custom-power:hover,
  #window:hover,
  #language:hover,
  #custom-wf-recorder:hover {
    box-shadow:
      inset 0 1px 0 ${glass_inner},
      0 6px 16px ${glass_shadow};
    border-color: ${glass_stroke};
  }
''
