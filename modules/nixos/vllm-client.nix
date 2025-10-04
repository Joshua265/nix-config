{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.vllmClient;
in {
  options.services.vllmClient = {
    enable = lib.mkEnableOption "NextChat + n8n client pointed at vLLM via local NGINX proxy";

    # Where your encrypted sops file lives (required)
    secretsFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to sops-encrypted secrets file that includes vllm_api_key, n8n_* keys";
      example = ./secrets/secrets.yaml;
    };

    # Upstream (desktop vLLM): root (no /v1) and the /v1 base for n8n
    upstreamRoot = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:8000";
      description = "OpenAI-compatible root URL of vLLM (no /v1)";
    };
    upstreamV1 = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:8000/v1";
      description = "OpenAI-compatible /v1 base used by n8n";
    };

    uiPort = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Local NextChat UI port";
    };

    # NextChat UI password (optional)
    code = lib.mkOption {
      type = lib.types.str;
      default = "local-only";
      description = "Optional password for the NextChat UI (comma-separated allowed). Empty disables.";
    };

    # Enable/disable n8n on this host
    enableN8n = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to run n8n on this machine";
    };

    # Age key (optional) if you want to set it per host
    ageKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to age key file for sops-nix (optional if set elsewhere)";
    };
  };

  config = lib.mkIf cfg.enable {
    # sops-nix wiring
    sops.defaultSopsFile = cfg.secretsFile;
    # only set age key if provided here
    sops.age.keyFile = lib.mkIf (cfg.ageKeyFile != null) cfg.ageKeyFile;

    users.groups.n8n = {};
    users.users.n8n = {
      isSystemUser = true;
      home = "/var/lib/n8n";
      shell = pkgs.runtimeShell;
      group = "n8n";
    };

    # Secrets we expect inside the file
    sops.secrets = {
      "vllm_api_key" = {};
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
    sops.templates."vllm-credentials.json".content = ''
      {
        "OpenAi": {
          "baseUrl": "${cfg.upstreamRoot}",
          "apiKey": "${config.sops.placeholder.vllm_api_key}"
        }
      }
    '';
    sops.templates."vllm-credentials.json".owner = "n8n";
    # Tailscale client(safe to enable on all)
    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale_auth_key".path;
    };

    # n8n (optional per host)
    services.n8n = lib.mkIf cfg.enableN8n {
      enable = true;
      openFirewall = true; # stays local unless reverse-proxied
    };
    systemd.services.n8n.serviceConfig = {
      Environment = [
        "N8N_HOST=localhost"
        "N8N_PORT=5678"
        "N8N_PROTOCOL=http"

        "N8N_BASIC_AUTH_ACTIVE=true"
        "N8N_BASIC_AUTH_USER_FILE=${config.sops.secrets."n8n_basic_user".path}"
        "N8N_BASIC_AUTH_PASSWORD_FILE=${config.sops.secrets."n8n_basic_pass".path}"
        "N8N_ENCRYPTION_KEY_FILE=${config.sops.secrets."n8n_encryption_key".path}"

        "CREDENTIALS_OVERWRITE_DATA_FILE=${config.sops.templates."vllm-credentials.json".path}"
      ];
    };

    sops.templates."nextchat.env".content = ''
      BASE_URL = ${cfg.upstreamRoot};
      OPENAI_API_KEY =${config.sops.placeholder.vllm_api_key};
      CODE = cfg.code;
      HIDE_USER_API_KEY = "1";
      CUSTOM_MODELS = "-all,+meta-llama/Llama-3.1-8B-Instruct";
    '';

    # NextChat container
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.containers.nextchat = {
      image = "yidadaa/chatgpt-next-web:latest";
      # Expose to localhost only (or more, if you want remote)
      ports = ["127.0.0.1:${toString cfg.uiPort}:3000"];

      environmentFiles = [config.sops.templates."nextchat.env".path];
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [cfg.uiPort] ++ lib.optionals cfg.enableN8n [5678];
    };
  };
}
