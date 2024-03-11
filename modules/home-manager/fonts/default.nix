{pkgs, ...}: {
  home.packages = with pkgs; [
    # icon fonts
    material-symbols

    # Sans(Serif) fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    roboto
    (google-fonts.override {fonts = ["Inter"];})

    # monospace fonts
    jetbrains-mono

    # nerdfonts
    (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
  ];
  fonts.fontconfig.enable = true;
}
