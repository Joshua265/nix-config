{
  home,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    xournalpp

    python312Packages.evdev
    xdotool
    zathura

    nautilus

    firefox
  ];
}
