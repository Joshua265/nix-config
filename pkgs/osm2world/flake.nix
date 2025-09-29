{
  description = "Flake for OSM2World";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    lib = pkgs.lib;

    osm2worldZip = pkgs.fetchzip {
      # Update the URL and sha256 when new release
      url = "https://osm2world.org/download/files/latest/OSM2World-latest-bin.zip";
      stripRoot = false;
      sha256 = "sha256-+iiEPonYLLETmPa0iTgl2oNkXXfO96PIEbaUgys/dbc=";
      # Note: you must replace the sha256 above with the correct one you get from `nix-prefetch-url` or similar.
    };

    # Or pin 0.4.0 (recommended for reproducibility)
    # osm2worldZip = pkgs.fetchzip {
    #   url = "https://osm2world.org/download/files/0.4.0/OSM2World-0.4.0-bin.zip";
    #   stripRoot = false;
    #   sha256 = "<fill-with-nix-prefetch-url--unpack>";
    # };

    jar = "${osm2worldZip}/OSM2World.jar";

    # Libraries AWT/JOGL may dlopen at runtime
    xglLibs = [
      pkgs.xorg.libX11
      pkgs.xorg.libXext
      pkgs.xorg.libXtst
      pkgs.xorg.libXi
      pkgs.xorg.libXrender
      pkgs.xorg.libXrandr
      pkgs.xorg.libXcursor
      pkgs.xorg.libXfixes
      pkgs.freetype
      pkgs.fontconfig
      pkgs.libGL
      pkgs.libglvnd
      pkgs.mesa
    ];

    libPath = lib.makeLibraryPath xglLibs;

    osm2world = pkgs.writeShellApplication {
      name = "osm2world";
      # Use *full* JDK (AWT/Swing present), not headless
      runtimeInputs = [pkgs.jdk17] ++ xglLibs;
      text = ''
        # Default to CLI help when no args, so we don't auto-launch GUI
        if [ $# -eq 0 ]; then
          set -- --help
        fi

        # For pure CLI use on headless servers, you can uncomment the next line:
        # export _JAVA_OPTIONS="$_JAVA_OPTIONS -Djava.awt.headless=true"

        export LD_LIBRARY_PATH="LD_LIBRARY_PATH:${libPath}"
        exec java -jar "${jar}" "$@"
      '';
    };
  in {
    packages.${system}.default = osm2world;
    apps.${system}.default = {
      type = "app";
      program = "${osm2world}/bin/osm2world";
    };
  };
}
