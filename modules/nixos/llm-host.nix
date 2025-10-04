{
  config,
  pkgs,
  lib,
  ...
}: let
  llmPort = 8000;
in {
  ########################
  # Secrets via sops-nix #
  ########################
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/user/.config/sops/age/keys.txt";

  sops.secrets = {
    "tailscale_auth_key" = {};
  };

  ################
  # Tailscale    #
  ################
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale_auth_key".path;
  };

  ################
  # Firewall     #
  ################
  networking.firewall = {
    enable = true;
    interfaces.tailscale0.allowedTCPPorts = [llmPort];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  ###################################
  # Container runtime for vLLM      #
  ###################################
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama;
    # GPU: pick one of "cuda" | "rocm" | null (auto). For NVIDIA use "cuda".
    acceleration = "cuda";
    host = "0.0.0.0";
    port = llmPort;
    # Pre-pull models at service start (optional but handy)
    loadModels = ["llama3.1:8b" "gpt-oss:20b"];
    # Allow your NextChat origin(s) to call Ollama (CORS)
    environmentVariables = {
      # Examples; trim to what you actually use:
      OLLAMA_ORIGINS = "http://localhost:3000,http://localhost:5678";
    };
  };
}
