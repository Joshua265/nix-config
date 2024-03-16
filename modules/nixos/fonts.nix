{pkgs, ...}: {
  fonts.packages = with pkgs; [
    # icon fonts
    material-symbols

    # Sans(Serif) fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    roboto
    google-fonts

    # Serif fonts
    profont

    # nerdfonts
    nerdfonts
  ];
  fonts.enableDefaultFonts = false;
}
