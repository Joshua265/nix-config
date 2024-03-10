{
  config,
  pkgs,
  lib,
  ...
}: {
  gtk = {
    enable = true;
    theme.name = "Nordic";
    theme.package = pkgs.nordic;
  };
}
