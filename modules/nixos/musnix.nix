{
  pkgs,
  config,
  ...
}: {
  musnix.enable = true;

  musnix.soundcardPciId = "00:1f.3";

  # musnix.kernel.realtime = true;
}
