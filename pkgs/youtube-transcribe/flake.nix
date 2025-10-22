{
  description = "A flake for the youtube-transcribe Rust project";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Using unstable for latest features

    # Utility for flake boilerplate
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # Dependencies required for building the Rust package.
        # These are tools and libraries needed during the build process.
        nativeBuildInputs = with pkgs; [
          pkg-config # For pkg-config integration
          rustc # The Rust compiler
          cargo # The Rust build tool
          git # May be needed for fetching sources or Git-related build steps
          wrapGAppsHook # For wrapping GTK applications
        ];

        # Libraries that the Rust code links against.
        buildInputs = with pkgs; [
          gtk4 # GTK4 library for GUI
          libadwaita # Libadwaita library for GTK4 theming
          glib # GLib library, a dependency for GTK and others
          gsettings-desktop-schemas # GTK settings schemas
          openssl # For TLS support in reqwest
          zlib # Compression library
          which # Utility to find executables
        ];

        # Dependencies that the final executable needs to run.
        # These will be made available in the package's PATH.
        runtimeDependencies = with pkgs; [
          yt-dlp # For downloading videos
          ffmpeg # For video/audio processing
          whisper-cpp # Whisper C++ CLI
          glib # Also a runtime dependency
          openssl # Also a runtime dependency
          zlib # Also a runtime dependency
          which # Also a runtime dependency
        ];
      in {
        # Package output: defines how to build the youtube-transcribe application.
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "youtube-transcribe";
          version = "0.1.0";

          src = ./.; # Source code is in the current directory

          cargoHash = "sha256-GBV2RBBpqhivTTAzgkTCUajz+8OKMq08pz82XdS7BXQ=";

          cargoBuildType = "release"; # Build in release mode for performance

          nativeBuildInputs = nativeBuildInputs;
          buildInputs = buildInputs;

          preFixup = ''
            gappsWrapperArgs+=(
              --prefix PATH : ${pkgs.lib.makeBinPath runtimeDependencies}
            )
          '';
        };

        # Development shell: provides an environment with all necessary tools and dependencies.
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.pkg-config
            pkgs.rustc
            pkgs.cargo
            pkgs.cargo-edit
            pkgs.git
            pkgs.gtk4
            pkgs.libadwaita
            pkgs.glib
            pkgs.openssl
            pkgs.zlib
            pkgs.which
            pkgs.yt-dlp
            pkgs.ffmpeg
            pkgs.whisper-cpp-vulkan
          ];
          # Optional: Add environment variables or shell hooks for development.
          # For example, to help rust-analyzer find sources:
          # shellHook = ''
          #   export RUST_SRC_PATH=${pkgs.rust.src}/library
          # '';
        };
      }
    );
}
