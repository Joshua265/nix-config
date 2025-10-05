{
  config,
  pkgs,
  lib,
  ...
}: let
  # Ports (only UIs are bound to localhost)
  n8nPort = 5678;
  webUiPort = 8080;

  # Network names
  internalNet = "ai_internal"; # internal-only, no egress
  edgeNet = "ai_edge"; # for binding localhost UI ports

  # Convenience: container unit names so we can wire systemd deps
  svc = {
    postgres = "docker-postgres";
    n8n = "docker-n8n";
    ollama = "docker-ollama";
    owui = "docker-openwebui";
    qdrant = "docker-qdrant";
  };
in {
  #################################
  # Runtime and GPU prerequisites #
  #################################
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  # NVIDIA Container Toolkit via CDI (modern way).
  # See notes below if you prefer --gpus=all.
  hardware.nvidia-container-toolkit.enable = true; # CDI publishes devices for Docker/Podman

  ########################
  # Secrets via sops-nix #
  ########################
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/user/.config/sops/age/keys.txt";
  sops.secrets = {
    "tailscale_auth_key" = {};
    "n8n_postgres_password" = {mode = "0444";};
    "n8n_encryption_key" = {mode = "0444";};
    "n8n_basic_user" = {mode = "0444";};
    "n8n_basic_pass" = {mode = "0444";};
  };
  ################
  # Firewall     #
  ################
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale_auth_key".path;
  };
  networking.firewall = {
    enable = true;
    # Expose services only over the Tailscale interface
    interfaces.tailscale0.allowedTCPPorts = [webUiPort n8nPort];
    allowedUDPPorts = [config.services.tailscale.port];
  };
  ############################################
  # Create Docker networks (idempotent, boot)#
  ############################################
  systemd.services."docker-net-${internalNet}" = {
    description = "Create internal Docker network ${internalNet}";
    after = ["docker.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network inspect ${internalNet} >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create --internal ${internalNet}
    '';
  };
  systemd.services."docker-net-${edgeNet}" = {
    description = "Create edge Docker network ${edgeNet}";
    after = ["docker.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network inspect ${edgeNet} >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create ${edgeNet}
    '';
  };

  #########################################
  # Containers (all traffic on internalNet)
  # Only UIs also join edgeNet + bind 127.0.0.1
  #########################################
  virtualisation.oci-containers.containers = {
    postgres = {
      serviceName = svc.postgres;
      autoStart = true;
      image = "postgres:16-alpine";
      networks = [internalNet];
      volumes = [
        "pgdata:/var/lib/postgresql/data"
        "${config.sops.secrets."n8n_postgres_password".path}:/run/secrets/n8n_postgres_password:ro"
      ];
      environment = {
        POSTGRES_USER = "n8n";
        POSTGRES_DB = "n8n";
        POSTGRES_PASSWORD_FILE = "/run/secrets/n8n_postgres_password";
      };
      extraOptions = [
        "--health-cmd=pg_isready -U n8n -d n8n -h 127.0.0.1"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=5"
        "--health-start-period=20s"
      ];
    };

    n8n = {
      serviceName = svc.n8n;
      autoStart = true;
      image = "n8nio/n8n:latest";
      networks = [internalNet edgeNet];
      # ports = ["127.0.0.1:${toString n8nPort}:5678"];
      volumes = [
        "n8n_data:/var/lib/n8n"
        "${config.sops.secrets."n8n_encryption_key".path}:/run/secrets/n8n_encryption_key:ro"
        "${config.sops.secrets."n8n_basic_user".path}:/run/secrets/n8n_basic_user:ro"
        "${config.sops.secrets."n8n_basic_pass".path}:/run/secrets/n8n_basic_pass:ro"
        "${config.sops.secrets."n8n_postgres_password".path}:/run/secrets/n8n_postgres_password:ro"
      ];
      environment = {
        N8N_HOST = "${config.networking.hostName}.ts.net"; # or your domain
        N8N_PORT = toString n8nPort;
        N8N_PROTOCOL = "http";
        N8N_EDITOR_BASE_URL = "http://${config.networking.hostName}:${toString n8nPort}";
        N8N_WEBHOOK_URL = "http://${config.networking.hostName}:${toString n8nPort}";
        N8N_DIAGNOSTICS_ENABLED = "false";
        N8N_PERSONALIZATION_ENABLED = "false";
        N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "true";
        N8N_BASIC_AUTH_ACTIVE = "true";

        DB_TYPE = "postgresdb";
        DB_POSTGRESDB_HOST = "postgres";
        DB_POSTGRESDB_PORT = "5432";
        DB_POSTGRESDB_DATABASE = "n8n";
        DB_POSTGRESDB_USER = "n8n";

        N8N_BASIC_AUTH_USER_FILE = "/run/secrets/n8n_basic_user";
        N8N_BASIC_AUTH_PASSWORD_FILE = "/run/secrets/n8n_basic_pass";

        # Encryption key from a mounted file
        N8N_ENCRYPTION_KEY_FILE = "/run/secrets/n8n_encryption_key";
        DB_POSTGRESDB_PASSWORD_FILE = "/run/secrets/n8n_postgres_password";
      };
      dependsOn = ["postgres"];
      extraOptions = [
        "--publish=127.0.0.1:${toString n8nPort}:5678"
        "--health-cmd=wget -qO- http://localhost:5678/healthz || exit 1"
        "--health-interval=30s"
        "--health-timeout=5s"
        "--health-retries=5"
        "--health-start-period=30s"
      ];
    };

    ollama = {
      serviceName = svc.ollama;
      autoStart = true;
      image = "ollama/ollama:latest";
      networks = [internalNet];
      volumes = ["/var/lib/ollama:/root/.ollama"];
      # CDI devices (set by hardware.nvidia-container-toolkit.enable)
      devices = ["nvidia.com/gpu=all"];
      environment = {
        OLLAMA_HOST = "0.0.0.0"; # listen inside container
      };
      # If you also want host access to API, add: ports = [ "127.0.0.1:11434:11434" ];
      extraOptions = [
        "--health-cmd=wget -qO- http://localhost:11434/api/version || exit 1"
        "--health-interval=30s"
        "--health-timeout=5s"
        "--health-retries=5"
        "--health-start-period=30s"
      ];
    };

    qdrant = {
      serviceName = svc.qdrant;
      autoStart = true;
      image = "qdrant/qdrant:latest";
      networks = [internalNet];
      volumes = ["/var/lib/qdrant:/qdrant/storage"];
      extraOptions = [
        "--health-cmd=wget -qO- http://localhost:6333/readyz || exit 1"
        "--health-interval=30s"
        "--health-timeout=5s"
        "--health-retries=10"
        "--health-start-period=30s"
      ];
    };

    openwebui = {
      serviceName = svc.owui;
      autoStart = true;
      image = "ghcr.io/open-webui/open-webui:main";
      networks = [internalNet edgeNet];
      # ports = ["127.0.0.1:${toString webUiPort}:8080"];
      volumes = ["/var/lib/openwebui:/app/backend/data"];
      environment = {
        OLLAMA_BASE_URL = "http://ollama:11434";
        VECTOR_DB = "qdrant";
        QDRANT_URL = "http://qdrant:6333";
        DEFAULT_USER_ROLE = "admin";
        WEBUI_URL = "http://localhost:${toString webUiPort}";
      };
      dependsOn = ["ollama" "qdrant"];
      extraOptions = [
        "--publish=127.0.0.1:${toString webUiPort}:8080"
        "--health-cmd=wget -qO- http://localhost:8080/health || exit 1"
        "--health-interval=30s"
        "--health-timeout=5s"
        "--health-retries=5"
        "--health-start-period=20s"
      ];
    };
  };

  ##########################################
  # Make containers wait for network units #
  ##########################################
  systemd.services.${svc.postgres}.after = ["docker-net-${internalNet}.service"];
  systemd.services.${svc.n8n}.after = ["docker-net-${internalNet}.service" "docker-net-${edgeNet}.service"];
  systemd.services.${svc.ollama}.after = ["docker-net-${internalNet}.service"];
  systemd.services.${svc.qdrant}.after = ["docker-net-${internalNet}.service"];
  systemd.services.${svc.owui}.after = ["docker-net-${internalNet}.service" "docker-net-${edgeNet}.service"];
}
