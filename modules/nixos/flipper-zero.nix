{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = [
    pkgs.qFlipper
  ];

  hardware.flipperzero.enable = true;

  users.users.${config.main-user.userName}.extraGroups = ["dialout"];
}
