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
    outputs.nixosModules.musnix
    outputs.nixosModules.llm-client

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # cachix
    ../../cachix.nix
  ];

  # hostname
  networking.hostName = "nixos-framework-13";

  # firmware-updates
  services.fwupd.enable = true;

  # Enable Sensor Data Reading
  hardware.sensor.iio.enable = true;

  services = {
    thermald.enable = true;

    tlp = {
      enable = true;
      settings = {
        # If your hardware supports it:
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;

        USB_AUTOSUSPEND = 1; # Auto-suspend USB

        # governors
        CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # Intel/AMD EPP (energy performance preference)
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power"; # or "power" for maximum savings

        # cap peak clocks on battery
        CPU_MAX_PERF_ON_BAT = 60; # try 60 first; 50 if you want more savings
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_AC = 0;

        # Optional: disable turbo on battery for big gains (test workload impact)
        CPU_BOOST_ON_BAT = 1;
      };
    };

    upower = {
      enable = true;
      criticalPowerAction = "HybridSleep";
    };
  };
  services.power-profiles-daemon.enable = false; # avoid conflicts with TLP
  services.auto-cpufreq.enable = false;

  # Powertop for profiling + autotune
  powerManagement.powertop.enable = true;

  # Prefer deep sleep, then auto-hibernate after 1h
  boot.kernelParams = ["mem_sleep_default=deep"];

  systemd.sleep.extraConfig = ''
    SuspendState=mem
    HibernateDelaySec=1h
  '';

  # Optional: also steer logind’s idle/lid actions
  services.logind = {
    # IdleAction="suspend-then-hibernate"; IdleActionSec="30min";
    # lidSwitch="suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=ignore
    '';
  };

  # Enable OpenGL support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    #    package = pkgs-hyprland.mesa;
    #    package32 = pkgs-hyprland.pkgsi686Linux.mesa;
  };

  services.llmClient = {
    enable = true;
    secretsFile = ../../secrets/secrets.yaml;
    ageKeyFile = "/home/user/.config/sops/age/keys.txt";
  };
}
