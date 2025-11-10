{
  description = "Joshua's nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    nixpkgs-legacy.url = "github:nixos/nixpkgs/nixos-24.11";

    nix-matlab = {
      # nix-matlab's Nixpkgs input follows Nixpkgs' nixos-unstable branch. However
      # your Nixpkgs revision might not follow the same branch. You'd want to
      # match your Nixpkgs and nix-matlab to ensure fontconfig related
      # compatibility.
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:doronbehar/nix-matlab";
    };

    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };

    nixGL.url = "github:guibou/nixGL";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Add any other flake you might need
    nixos-hardware = {url = "github:NixOS/nixos-hardware/master";};

    nix-colors.url = "github:misterio77/nix-colors";
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    hypridle = {
      url = "git+https://github.com/hyprwm/hypridle?submodules=1";
    };
    hyprlock = {
      url = "git+https://github.com/hyprwm/hyprlock?submodules=1";
    };
    hyprland-plugins = {
      url = "git+https://github.com/hyprwm/hyprland-plugins?submodules=1";
      inputs.hyprland.follows = "hyprland";
    };
    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland"; # IMPORTANT
    };
    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      inputs.hyprland.follows = "hyprland"; # <- make sure this line is present for the plugin to work as intended
    };
    nix-gaming.url = "github:fufexan/nix-gaming";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    rnix-lsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

    custom-nvim = {
      url = "github:Joshua265/neovim";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # musnix audio enhancements
    musnix = {url = "github:musnix/musnix";};

    # tree wide formatter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    youtube-transcribe-flake = {
      url = "path:./pkgs/youtube-transcribe";
      inputs.nixpkgs.follows = "nixpkgs";
      flake = true;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-xr,
    home-manager,
    nix-colors,
    youtube-transcribe-flake,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    system = "x86_64-linux";
    # Your custom packages and modifications, exported as overlays
    openglWrappedOverlay = final: prev:
      prev.lib.genAttrs ["kitty" "alacritty" "blender" "zen-browser" "freecad" "wasistlos" "bambu-studio"]
      (name: final.wrapWithNixGLIntel prev.${name});
    overlays = import ./overlays {inherit inputs system;};
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "mbedtls-2.28.10"
        ];
      };
      overlays = [
        overlays.additions
        overlays.legacy-packages
        overlays.unstable-packages
        overlays.nixGLOverlay
        overlays.modifications
        openglWrappedOverlay
        inputs.nix-matlab.overlay
      ];
    };
    pkgsCuda = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        cudaSupport = true;
        cudnnSupport = true;
        cudaCapabilities = ["8.6"];
        permittedInsecurePackages = [
          "mbedtls-2.28.10"
        ];
      };
      overlays = [
        overlays.additions
        overlays.legacy-packages
        overlays.unstable-packages
        overlays.nixGLOverlay
        overlays.modifications
        openglWrappedOverlay
        inputs.nix-matlab.overlay
      ];
    };
  in {
    # format pre commit hooks
    pre-commit = {
      settings.excludes = ["flake.lock"];

      settings.hooks = {
        alejandra.enable = true;
        prettier.enable = true;
      };
    };

    # configure treefmt
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        alejandra.enable = true;
        black.enable = true;
        deadnix.enable = false;
        shellcheck.enable = true;
        shfmt = {
          enable = true;
          indent_size = 2;
        };
      };
    };

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixos-desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/desktop/configuration.nix
          # > Our main home-manager configuration file <
          home-manager.nixosModules.home-manager
          nixpkgs-xr.nixosModules.nixpkgs-xr
          inputs.musnix.nixosModules.musnix
          inputs.sops-nix.nixosModules.sops
          {nixpkgs.pkgs = pkgsCuda;}
          {
            home-manager.users.user = import ./home-manager/desktop/home.nix;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit inputs outputs pkgs nix-colors youtube-transcribe-flake;
            };
          }
        ];
      };
      nixos-surface = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/surface/configuration.nix
          # > Our main home-manager configuration file <
          home-manager.nixosModules.home-manager
          inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
          {nixpkgs.pkgs = pkgs;}
          {
            home-manager.users.user = import ./home-manager/surface/home.nix;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit inputs outputs nix-colors youtube-transcribe-flake;
            };
          }
        ];
      };
      nixos-framework = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/framework/configuration.nix
          # > Our main home-manager configuration file <
          home-manager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series1
          {nixpkgs.pkgs = pkgs;}
          {
            home-manager.users.user = import ./home-manager/framework/home.nix;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit inputs outputs pkgs nix-colors youtube-transcribe-flake;
            };
          }
        ];
      };
    };
  };
}
