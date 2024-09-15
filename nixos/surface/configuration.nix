# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: 
let 
pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.system};
in
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.discord
    outputs.nixosModules.display-manager
    outputs.nixosModules.auto-upgrade
    outputs.nixosModules.security
    outputs.nixosModules.fonts
    # outputs.nixosModules.musnix
    outputs.nixosModules.main-user

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # cachix
    ../../cachix.nix
  ];

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nixpkgs.config.allowUnfree = true;

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.xserver.videoDrivers = ["intel"];

  environment.sessionVariables = {
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  # WIFI
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    IPv6 = {
      Enabled = true;
    };
    Settings = {
      AutoConnect = true;
    };
  };
  networking.networkmanager.wifi.backend = "iwd";

  # Bluetooth
  hardware.bluetooth.enable = true;

  # hostname
  networking.hostName = "nixos-surface";

  # Bootloader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = false;
    };
  };

  # auto detect disks and usb devices
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # User accounts
  main-user.enable = true;
  main-user.userName = "user";

  # important packages and dependencies
  environment.systemPackages = with pkgs; [
    wget
    curl
    htop
    tree
    tmux
    which
    fd
    python3
    glib
    libgcc
    zlib
    sysstat
    lm_sensors # for `sensors` command
    neofetch
    ethtool
    pciutils # lspci
    usbutils # lsusb
    gparted
    unzip
    ntfs3g # NTFS disk support
    tlp # battery saving
    powertop # battery consumption monitoring
  ];

#  services.thermald.enable = true;
#  services.tlp = {
#    enable = true;
#    settings = {
#      CPU_SCALING_GOVERNOR_ON_AC = "performance";
#      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";#

#      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
#      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

#      CPU_MIN_PERF_ON_AC = 0;
#      CPU_MAX_PERF_ON_AC = 100;
#      CPU_MIN_PERF_ON_BAT = 0;
#      CPU_MAX_PERF_ON_BAT = 80;

      #Optional helps save long term battery health
      # START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      # STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
#   };
#  };

  services.upower.enable = true;
  services.upower.criticalPowerAction = "Hibernate";
  services.logind.lidSwitch = "hibernate";
  services.logind.extraConfig = ''
    HandlePowerKey=hibernate
  '';

  # intel fixes
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "nvme.noacpi=1"
    "i915.enable_psr=1"
  ];
  # boot.kernelPackages = pkgs.linuxPackages_6_0;
#  nixpkgs.config.packageOverrides = pkgs: {
 #   vaapiIntel = pkgs.vaapiIntel.override {
  #    enableHybridCodec = true;
#    };
 # };  

  # Enable OpenGL support
  hardware.opengl.enable = true;
  hardware.opengl.package = pkgs-hyprland.mesa.drivers;
#  hardware.opengl.extraPackages = with pkgs; [
#    vaapiIntel
#    libvdpau-va-gl
#    intel-media-driver
#  ];

  services.flatpak.enable = false; # only for games
  xdg.portal.enable = false; # only for games

  # Spotify track sync with other devices
  # TODO: move
  networking.firewall.allowedTCPPorts = [57621];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
