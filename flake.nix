{
  description = "Joshua's nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-personal.url = "github:Joshua265/nixpkgs/master";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Add any other flake you might need
    nixos-hardware = {url = "github:NixOS/nixos-hardware/master";};
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "git+https://github.com/hyprwm/hyprland-plugins?submodules=1";
      inputs.hyprland.follows = "hyprland";
    };
    nix-gaming.url = "github:fufexan/nix-gaming";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    rnix-lsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

    # musnix audio enhancements
    musnix = {url = "github:musnix/musnix";};

    # tree wide formatter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-xr,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    system = "x86_64-linux";
    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        overlays.unstable-packages
        overlays.personal-packages
        overlays.additions
      ];
    };
    lib = nixpkgs.lib;
    # dev shells
    pythonEnv = import ./shells/python-env.nix;
    nodeEnv = import ./shells/node-env.nix;
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

    # dev shells
    devShells.x86_64-linux = {
      # pythonEnv = pythonEnv;
      nodeEnv = nodeEnv;
    };

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
          {
            home-manager.users.user = import ./home-manager/desktop/home.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs outputs pkgs;
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
          {
            home-manager.users.user = import ./home-manager/surface/home.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs outputs pkgs;
            };
          }
        ];
      };
    };
  };
}
