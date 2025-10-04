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
    outputs.nixosModules.llm-host
    outputs.nixosModules.llm-client

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # cachix
    ../../cachix.nix
  ];

  programs.noisetorch.enable = true;

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };

  # hostname
  networking.hostName = "nixos-desktop";
  networking.hostId = "8374973e";

  hardware.keyboard.zsa.enable = true;

  # Temp zfs setup
  boot.kernelModules = ["zfs"];

  services.vllmClient = {
    enable = true;
    secretsFile = ../../secrets/secrets.yaml;
    ageKeyFile = "/home/user/.config/sops/age/keys.txt";

    # Desktop client → local vLLM
    upstreamRoot = "http://127.0.0.1:8000";
    upstreamV1 = "http://127.0.0.1:8000/v1";

    uiPort = 3000;

    code = "local-only"; # optional UI password
    enableN8n = true; # or false if you don't want n8n on the desktop
  };
}
