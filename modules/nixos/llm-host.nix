{
  config,
  pkgs,
  lib,
  ...
}: let
  llmPort = 8000; # Ollama/vLLM (here: Ollama)
  webUiPort = 3000; # Open WebUI
  n8nPort = 5678; # n8n
in {
  ########################
  # Secrets via sops-nix #
  ########################
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/user/.config/sops/age/keys.txt";

  # Keep/extend your secrets set as needed
  sops.secrets = {
    "tailscale_auth_key" = {};
    "n8n_encryption_key" = {
      owner = "n8n";
      group = "n8n";
      mode = "0400";
    };
    "n8n_basic_user" = {
      owner = "n8n";
      group = "n8n";
      mode = "0400";
    };
    "n8n_basic_pass" = {
      owner = "n8n";
      group = "n8n";
      mode = "0400";
    };
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
    # Expose services only over the Tailscale interface
    interfaces.tailscale0.allowedTCPPorts = [llmPort webUiPort n8nPort];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  ###################################
  # Ollama (LLM server on the host) #
  ###################################
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama;
    acceleration = "cuda"; # or "rocm" | null
    host = "0.0.0.0";
    port = llmPort;
    # CORS not strictly needed when OWUI calls via server→server,
    # but harmless to keep for local testing.
    environmentVariables = {
      OLLAMA_ORIGINS = "http://localhost:${toString webUiPort}";
    };
    # Optionally pre-pull models:
    loadModels = ["llama3.1:8b" "gpt-oss:20b"];
  };

  ################
  # n8n on host  #
  ################
  users.groups.n8n = {};
  users.users.n8n = {
    isSystemUser = true;
    home = "/var/lib/n8n";
    shell = pkgs.runtimeShell;
    group = "n8n";
  };

  services.n8n = {
    enable = true;
    openFirewall = false; # we control exposure via tailscale0 only
  };

  # n8n runtime env (UI + webhooks reachable over Tailscale/MagicDNS)
  systemd.services.n8n.serviceConfig.Environment = [
    # Set these 2 to your actual Tailscale MagicDNS name if you use it:
    # e.g. "myhost.your-tailnet.ts.net"
    "N8N_HOST=${config.networking.hostName}.ts.net"
    "N8N_EDITOR_BASE_URL=http://${config.networking.hostName}:${toString n8nPort}"
    # Webhook URLs used by triggers (important for external calls)
    "N8N_WEBHOOK_URL=http://${config.networking.hostName}:${toString n8nPort}"

    "N8N_PORT=${toString n8nPort}"
    "N8N_PROTOCOL=http"
    "N8N_DIAGNOSTICS_ENABLED=false"
    "N8N_PERSONALIZATION_ENABLED=false"

    "N8N_BASIC_AUTH_ACTIVE=true"
    "N8N_BASIC_AUTH_USER_FILE=${config.sops.secrets."n8n_basic_user".path}"
    "N8N_BASIC_AUTH_PASSWORD_FILE=${config.sops.secrets."n8n_basic_pass".path}"
    "N8N_ENCRYPTION_KEY_FILE=${config.sops.secrets."n8n_encryption_key".path}"
  ];

  ########################################
  # Add Open WebUI (as the chat frontend)
  ########################################
  virtualisation.oci-containers = {
    backend = "docker";
    containers.openwebui = {
      image = "ghcr.io/open-webui/open-webui:main";
      # Bind to localhost; reach it via Tailscale proxy or SSH tunnel if needed.
      ports = ["127.0.0.1:${toString webUiPort}:8080"];
      volumes = ["/var/lib/openwebui:/app/backend/data"];
      extraOptions = ["--add-host=host.docker.internal:host-gateway"];
      environment = {
        # Point OWUI to your host Ollama
        OLLAMA_BASE_URL = "http://host.docker.internal:${toString llmPort}";
        # Set the public URL of OWUI if you later put it behind a reverse proxy.
        WEBUI_URL = "http://localhost:${toString webUiPort}";
        # Lock down signups by default (use Admin to invite users)
        DEFAULT_USER_ROLE = "admin";
      };
    };
  };

  # Ensure data dir exists for OWUI
  system.activationScripts.openwebui-data = {
    text = ''
      install -d -m0750 -o root -g root /var/lib/openwebui
    '';
  };
}
