{
  config,
  pkgs,
  lib,
  ...
}: let
  vllmPort = 8000;
in {
  ########################
  # Secrets via sops-nix #
  ########################
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/user/.config/sops/age/keys.txt";

  sops.secrets = {
    "tailscale_auth_key" = {};
    "vllm_api_key" = {};
    "hf_token" = {};
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
    interfaces.tailscale0.allowedTCPPorts = [vllmPort];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  ###################################
  # Container runtime for vLLM      #
  ###################################
  virtualisation.docker = {
    enable = true;
  };
  virtualisation.oci-containers = {
    backend = "docker";
    containers.vllm = {
      image = "vllm/vllm-openai:latest";
      extraOptions = ["--ipc=host"];
      ports = ["0.0.0.0:${toString vllmPort}:${toString vllmPort}"];
      volumes = ["/var/cache/vllm/huggingface:/root/.cache/huggingface"];
      devices = ["nvidia.com/gpu=all"];
      environment = {
        HUGGING_FACE_HUB_TOKEN = config.sops.secrets."hf_token".path;
        VLLM_API_KEY = config.sops.secrets."vllm_api_key".path;
      };
      cmd = [
        "--model"
        "meta-llama/Llama-3.1-8B-Instruct"
        "--host"
        "0.0.0.0"
        "--port"
        "${toString vllmPort}"
        "--gpu-memory-utilization"
        "0.90"
      ];
    };
  };
}
