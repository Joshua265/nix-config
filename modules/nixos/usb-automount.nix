{
  config,
  pkgs,
  lib,
  ...
}: let
  automountScript = pkgs.writeShellScriptBin "automount.sh" ''
    #!/bin/sh
    device=$DEVNAME
    mount_point="/mnt/usb-$(basename $device)"
    mkdir -p $mount_point
    udisksctl mount --no-user-interaction --block-device $device --mount-point $mount_point
  '';
in {
  # Ensure udisks2 is available
  environment.systemPackages = with pkgs; [
    udisks2
  ];

  # Define the udev rule directly in the NixOS configuration
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_BUS}=="usb", ENV{UDISKS_PRESENTATION_NOPOLICY}="0", RUN+="${automountScript}/bin/automount.sh"
  '';
}
