{
  description = "A flake for the youtube-transcribe Rust project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = nixpkgs.lib.systems.flakeExposed;
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        nativeBuildInputs = with pkgs; [
          pkg-config
          rustc
          cargo
          git
          wrapGAppsHook3
        ];

        buildInputs = with pkgs; [
          gtk4
          libadwaita
          glib
          gsettings-desktop-schemas
          openssl
          zlib
          which
        ];

        runtimeDependencies = with pkgs; [
          yt-dlp
          ffmpeg
          whisper-cpp
          glib
          openssl
          zlib
          which
        ];
      in {
        default = pkgs.rustPlatform.buildRustPackage {
          pname = "youtube-transcribe";
          version = "0.1.0";

          src = ./.;

          cargoHash = "sha256-GBV2RBBpqhivTTAzgkTCUajz+8OKMq08pz82XdS7BXQ=";
          cargoBuildType = "release";

          inherit nativeBuildInputs buildInputs;

          preFixup = ''
            gappsWrapperArgs+=(
              --prefix PATH : ${pkgs.lib.makeBinPath runtimeDependencies}
            )
          '';
        };
      }
    );

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
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
        };
      }
    );
  };
}
