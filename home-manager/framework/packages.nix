{
  home,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    matlab
  ];
}
