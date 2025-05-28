{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.clamav
    outputs.nixosModules.discord
    outputs.nixosModules.docker
    outputs.nixosModules.display-manager
    outputs.nixosModules.auto-upgrade
    outputs.nixosModules.security
    outputs.nixosModules.fonts
    outputs.nixosModules.musnix
    outputs.nixosModules.main-user
    outputs.nixosModules.usb-automount
    outputs.nixosModules.flipper-zero

    # cachix
    ../../cachix.nix
  ];

  # Flake registry and legacy channels
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  # WIFI
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };

  # Time and locale
  time.timeZone = "Europe/Berlin";
  time.hardwareClockInLocalTime = true;

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

  # Printing
  services.printing.enable = true;

  # Sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # media-session.enable = true; # default
  };

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 10d";
  };

  # Udev for PlatformIO
  services.udev.packages = [
    pkgs.platformio-core.udev
    pkgs.openocd
  ];

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Main user
  main-user.enable = true;
  main-user.userName = "user";

  programs.fish.enable = true; # enable fish shell
  users.users.${config.main-user.userName}.shell = pkgs.fish; # set fish as default shell

  # System packages (intersection + superset)
  environment.systemPackages = with pkgs; [
    wget
    bacon
    cargo
    cargo-info
    curl
    du-dust
    dua
    htop
    hyperfine
    tree
    tmux
    fish
    fselect
    gitui
    ripgrep
    ripgrep-all
    which
    fd
    jq
    bat
    uutils-coreutils-noprefix
    mprocs
    eza
    python3
    glib
    libgcc
    zlib
    presenterm
    rusty-man
    sysstat
    starship
    tokei
    lm_sensors
    freshfetch
    ethtool
    pciutils
    usbutils
    gparted
    unzip
    ntfs3g
    wiki-tui
    xh
    zfs
    zoxide
    zip
    unzip
  ];

  # Auto detect disks and usb devices
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Spotify track sync with other devices
  networking.firewall.allowedTCPPorts = [57621];

  # State version
  system.stateVersion = "24.11";
}
