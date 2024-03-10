{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Work around #159267
    (pkgs.writeShellApplication {
      name = "discord";
      text = "${pkgs.discord}/bin/discord --use-gl=desktop";
    })
    (pkgs.makeDesktopItem {
      name = "discord";
      exec = "discord";
      desktopName = "Discord";
    })
  ];
}
