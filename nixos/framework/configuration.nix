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

    # NixOS modules
    outputs.nixosModules.fingerprint

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # cachix
    ../../cachix.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # hostname
  networking.hostName = "nixos-framework-13";

  # Bootloader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = false;
      configurationLimit = 25;
    };
  };

  # firmware-updates
  services.fwupd.enable = true;

  # Enable Sensor Data Reading
  hardware.sensor.iio.enable = true;

  services = {
    thermald.enable = true;

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "powersave"; # More conservative
        CPU_SCALING_GOVERNOR_ON_BAT = "low-power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance-performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "low-power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100; # or lower if desired
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 70; # lower from 80 to 70 or even less

        # If your hardware supports it:
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;

        USB_AUTOSUSPEND = 1; # Auto-suspend USB
      };
    };

    upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
    };
  };

  # Enable OpenGL support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    #    package = pkgs-hyprland.mesa;
    #    package32 = pkgs-hyprland.pkgsi686Linux.mesa;
  };
}
