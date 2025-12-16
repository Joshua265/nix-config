{
  pkgs,
  lib,
  ...
}: {
  fonts.packages = with pkgs;
    [
      # icon fonts
      material-symbols
      powerline-symbols

      # Sans(Serif) fonts
      powerline-fonts
      font-awesome
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      roboto
      google-fonts

      # Serif fonts
      profont

      # Onlyoffice fonts
      corefonts
    ]
    ++ builtins.filter pkgs.lib.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  fonts.enableDefaultPackages = false;
}
