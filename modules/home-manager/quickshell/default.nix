{
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.quickshell = {
    enable = true;
    package = inputs.quickshell.packages.${pkgs.system}.default
      .withModules (
      with pkgs; [
        qt6.qtsvg
        qt6.qtimageformats
        qt6.qtmultimedia
        qt6.qt5compat
      ]
    );
  };
}
