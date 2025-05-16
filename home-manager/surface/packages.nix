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
    zathura-ps

    nautilus

    firefox
  ];
}
