{services, ...}: {
  services.xserver.digimend.enable = true;

  services.xserver.inputClassSections = [
    ''
      Identifier "XP-Pen 21.5 inch PenDisplay"
      MatchUSBID "28bd:091e"
      MatchIsTablet "on"
      MatchDevicePath "/dev/input/event*"
      Driver "wacom"
    ''
    ''
      Identifier "XP-Pen 21.5 inch PenDisplay"
      MatchUSBID "28bd:091e"
      MatchIsKeyboard "on"
      MatchDevicePath "/dev/input/event*"
      Driver "libinput"
    ''
  ];
}
