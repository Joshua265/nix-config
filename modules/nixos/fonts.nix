{
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) ["corefonts"];
  fonts.packages = with pkgs; [
    # icon fonts
    material-symbols
    powerline-symbols

    # Sans(Serif) fonts
    powerline-fonts
    font-awesome
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    roboto
    google-fonts

    # Serif fonts
    profont

    # nerdfonts
    nerdfonts

    # Onlyoffice fonts
    corefonts
  ];
  fonts.enableDefaultPackages = false;
}
