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

    # Local ports
    proxyPort = lib.mkOption {
      type = lib.types.port;
      default = 7999;
      description = "Local NGINX proxy port (injects Authorization header)";
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

    # Environment for n8n (uses /v1)
    sops.templates."llm-client.env".content = ''
      OPENAI_API_BASE=${cfg.upstreamV1}
      OPENAI_API_KEY=${config.sops.placeholder."vllm_api_key"}
    '';

    # Tailscale client (safe to enable on all)
    services.tailscale.enable = true;

    # n8n (optional per host)
    services.n8n = lib.mkIf cfg.enableN8n {
      enable = true;
      openFirewall = true; # stays local unless reverse-proxied
    };
    systemd.services.n8n.serviceConfig.EnvironmentFile =
      lib.mkIf cfg.enableN8n [config.sops.templates."llm-client.env".path];

    # NGINX proxy (inject Authorization)
    sops.templates."nginx-vllm-auth.conf".content = ''
      proxy_set_header Authorization "Bearer ${config.sops.placeholder."vllm_api_key"}";
    '';

    services.nginx = {
      enable = true;
      virtualHosts."nextchat-proxy.local" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = cfg.proxyPort;
          }
        ];
        locations."/v1/".proxyPass = "${cfg.upstreamRoot}/v1/";
        locations."/v1/".extraConfig = ''
          proxy_set_header Authorization "";
          include ${config.sops.templates."nginx-vllm-auth.conf".path};
        '';
      };
    };

    # NextChat container
    virtualisation.docker.enable = true;
    virtualisation.oci-containers = {
      backend = "docker";
      containers.nextchat = {
        image = "yidadaa/chatgpt-next-web:latest";
        ports = ["127.0.0.1:${toString cfg.uiPort}:3000"];
        environment = {
          BASE_URL = "http://127.0.0.1:${toString cfg.proxyPort}";
          OPENAI_API_KEY = "dummy"; # proxy injects real header
          CODE = cfg.code;
          HIDE_USER_API_KEY = "1";
        };
      };
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [cfg.proxyPort cfg.uiPort] ++ lib.optionals cfg.enableN8n [5678];
    };
  };
}
