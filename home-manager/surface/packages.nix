{
  home,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    xournalpp

    python3Packages.python-evdev
    xdotool
    zathura
    zathura-ps

    nautilus

    firefox
  ];
}
