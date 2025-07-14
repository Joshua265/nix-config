{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # (steam.override {
    #   extraPkgs = pkgs: [monado openhmd];
    # })
    # .run
    steam.run
  ];

  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;

  services.udev.extraRules = ''
    # Switch 2 Pro Controller – USB & BT
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2011", \
        MODE="0660", TAG+="uaccess"
  '';
}
