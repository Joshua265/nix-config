{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.llmClient;
in {
  options.services.llmClient = {
    enable = lib.mkEnableOption "Tailscale route to LLM services";
    secretsFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to sops-encrypted secrets file that includes vllm_api_key, n8n_* keys";
      example = ./secrets/secrets.yaml;
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
      "tailscale_auth_key" = {};
    };

    # Tailscale client(safe to enable on all)
    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale_auth_key".path;
    };
  };
}
