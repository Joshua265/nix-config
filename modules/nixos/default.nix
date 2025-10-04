# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  auto-rotate = import ./auto-rotate.nix;
  auto-brightness = import ./auto-brightness.nix;
  clamav = import ./clamav.nix;
  cuda = import ./cuda.nix;
  nvidia = import ./nvidia.nix;
  discord = import ./discord.nix;
  display-manager = import ./display-manager.nix;
  docker = import ./docker.nix;
  auto-upgrade = import ./auto-upgrade.nix;
  security = import ./security.nix;
  gamemode = import ./gamemode.nix;
  fonts = import ./fonts.nix;
  xp-pen = import ./xp-pen.nix;
  musnix = import ./musnix.nix;
  main-user = import ./main-user.nix;
  usb-automount = import ./usb-automount.nix;
  flipper-zero = import ./flipper-zero.nix;
  surface-io-key = import ./surface-io-key.nix;
  fingerprint = import ./fingerprint.nix;
  steam = import ./steam.nix;
  grub = import ./grub;
  llm-host = import ./llm-host.nix;
  llm-client = import ./llm-client.nix;
}
