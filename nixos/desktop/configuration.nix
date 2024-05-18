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
    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.nvidia
    outputs.nixosModules.cuda
    outputs.nixosModules.discord
    outputs.nixosModules.display-manager
    outputs.nixosModules.auto-upgrade
    outputs.nixosModules.security
    outputs.nixosModules.gamemode
    outputs.nixosModules.fonts
    outputs.nixosModules.xp-pen
    outputs.nixosModules.musnix
    outputs.nixosModules.main-user
    outputs.nixosModules.usb-automount

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
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  # hostname
  networking.hostName = "nixos-desktop";

  # Bootloader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = true;
    };
  };

  # auto detect disks and usb devices
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

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
    jq
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
  ];

  services.flatpak.enable = true; # only for games
  xdg.portal.enable = true; # only for games
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk]; # only for games
  xdg.portal.config = {
    common = {
      default = [
        "gtk"
      ];
    };
    pantheon = {
      default = [
        "pantheon"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [
        "gnome-keyring"
      ];
    };
    x-cinnamon = {
      default = [
        "xapp"
        "gtk"
      ];
    };
  };

  # Spotify track sync with other devices
  # TODO: move
  networking.firewall.allowedTCPPorts = [57621];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
