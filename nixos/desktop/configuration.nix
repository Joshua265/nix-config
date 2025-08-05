# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # Common shared configuration
    ../common/configuration.nix

    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.nvidia
    outputs.nixosModules.cuda
    outputs.nixosModules.xp-pen
    outputs.nixosModules.musnix

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # cachix
    ../../cachix.nix
  ];

  programs.noisetorch.enable = true;

  # hostname
  networking.hostName = "nixos-desktop";
  networking.hostId = "8374973e";

  networking.firewall = {
    # the firewall is enabled by default, keep it that way
    enable = true;

    # Steam / Core Keeper
    allowedTCPPorts = [27015 27036];

    # either list them …
    allowedUDPPorts = [
      27015
      27016
      27031
      27032
      27033
      27034
      27035
      27036
    ];
  };

  # Bootloader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 4;
    };
  };

  hardware.keyboard.zsa.enable = true;

  # Temp zfs setup
  boot.kernelModules = ["zfs"];
}
