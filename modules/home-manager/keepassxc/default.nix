# Code adapted from
# https://github.com/jtojnar/nixfiles/tree/4b3ff91f32f0b6f57383102a0d89d36d3d23dc92/common/configs/keepassxc
{
  pkgs,
  config,
  ...
}: let
  settings-directory = "$HOME/.config/keepassxc";
in {
  home.packages = with pkgs; [
    keepassxc
  ];

  home.file.".config/keepassxc/keepassxc.ini".source = ./keepassxc.ini;
  home.file.".mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json".source = pkgs.substituteAll {
    src = ./nmh.json;
    inherit (pkgs) keepassxc;
  };
}
