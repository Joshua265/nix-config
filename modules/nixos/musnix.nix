{inputs, ...}: {
  imports = [
    inputs.musnix.nixosModules.musnix
  ];
  musnix = {
    enable = true;

    soundcardPciId = "00:1f.3";

    # musnix.kernel.realtime = true;
  };
}
