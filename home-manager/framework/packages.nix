{
  home,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    freecad-wayland
  ];
}
