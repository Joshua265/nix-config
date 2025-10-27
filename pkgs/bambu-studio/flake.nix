{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.bambu-studio;

  # Helper: runtime GStreamer plugin paths (for live view / h264).
  gstPaths = lib.makeSearchPath "lib/gstreamer-1.0" [
    pkgs.gst_all_1.gst-plugins-base
    pkgs.gst_all_1.gst-plugins-good
    pkgs.gst_all_1.gst-plugins-bad
    pkgs.gst_all_1.gst-plugins-ugly
    pkgs.gst_all_1.gst-libav
  ];

  # Build from source following the wiki (deps first, then BambuStudio).
  bambuStudioFromSource = let
    versionTag = cfg.buildFromSource.versionTag;
    jpegVerArg =
      lib.optionalString (cfg.buildFromSource.jpegVersion != null)
      "-DJPEG_VERSION=${toString cfg.buildFromSource.jpegVersion}";
  in
    pkgs.stdenv.mkDerivation rec {
      pname = "bambu-studio";
      version = lib.removePrefix "v" versionTag;

      src = pkgs.fetchFromGitHub {
        owner = "bambulab";
        repo = "BambuStudio";
        rev = versionTag; # e.g. "v02.03.00.70"
        hash = lib.fakeSha256; # Replace via nix-prefetch after first build
      };

      nativeBuildInputs =
        [
          pkgs.cmake
          pkgs.ninja
          pkgs.pkg-config
          pkgs.wrapGAppsHook
          pkgs.extra-cmake-modules
          (
            if cfg.buildFromSource.useClang
            then pkgs.clang
            else null
          )
          pkgs.nasm
          pkgs.yasm
          pkgs.m4
        ]
        |> lib.filter (x: x != null);

      # Dependencies aligned with upstream wiki
      # (webkit2gtk 4.0 API; libsoup 2.4; Wayland bits; GL/OSMesa; GStreamer)
      buildInputs = [
        pkgs.gtk3
        pkgs.webkitgtk # 4.0 API expected by upstream today
        pkgs.libsoup_2_4
        pkgs.cairo
        pkgs.wayland
        pkgs.wayland-protocols
        pkgs.libxkbcommon
        pkgs.libGL
        pkgs.libGLU
        pkgs.libosmesa
        pkgs.xorg.libX11
        pkgs.x264
        pkgs.gstreamer
        pkgs.gst_all_1.gst-plugins-base
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
        pkgs.gst_all_1.gst-plugins-ugly
        pkgs.gst_all_1.gst-libav
      ];

      # Two-phase build, mirroring the wiki commands
      # 1) build deps into a DESTDIR
      # 2) build main BambuStudio with CMAKE_PREFIX_PATH to deps
      dontUseCmakeConfigure = true;

      enableParallelBuilding = true;

      buildPhase = ''
        set -euxo pipefail

        # Stage 1: deps
        mkdir -p deps/build deps/dest
        cmake -S deps -B deps/build -G Ninja \
          -DDESTDIR="$PWD/deps/dest" \
          -DCMAKE_BUILD_TYPE=Release \
          -DDEP_WX_GTK3=1 \
          ${jpegVerArg}
        cmake --build deps/build -j$NIX_BUILD_CORES

        # Stage 2: main
        mkdir -p build
        cmake -S . -B build -G Ninja \
          -DSLIC3R_STATIC=ON \
          -DSLIC3R_GTK=3 \
          -DBBL_RELEASE_TO_PUBLIC=1 \
          -DCMAKE_PREFIX_PATH="$PWD/deps/dest/usr/local" \
          -DCMAKE_INSTALL_PREFIX=$out \
          -DCMAKE_BUILD_TYPE=Release
        cmake --build build --target install -j$NIX_BUILD_CORES
      '';

      postFixup = ''
        # Ensure GStreamer can discover plugins at runtime.
        wrapProgram $out/bin/bambu-studio \
          --set GST_PLUGIN_SYSTEM_PATH_1_0 "${gstPaths}"
      '';

      meta = with lib; {
        homepage = "https://github.com/bambulab/BambuStudio";
        description = "PC software for BambuLab and other 3D printers";
        license = licenses.agpl3Plus;
        platforms = platforms.linux;
        maintainers = [];
      };
    };

  chosenPkg =
    if cfg.buildFromSource.enable
    then bambuStudioFromSource
    else pkgs.bambu-studio;
in {
  options.programs.bambu-studio = {
    enable = lib.mkEnableOption "Bambu Studio";

    package = lib.mkOption {
      type = lib.types.package;
      default = chosenPkg;
      description = ''
        Which package to install. Defaults to either the nixpkgs package
        or the in-module “buildFromSource” derivation if enabled.
      '';
    };

    buildFromSource = {
      enable = lib.mkEnableOption "Build Bambu Studio from source via two-phase deps + main build";

      # Use upstream tags like "v02.03.00.70" (latest as of Oct 14, 2025).
      # Fill the fetcher hash after the first attempt with nix-prefetch.
      versionTag = lib.mkOption {
        type = lib.types.str;
        default = "v02.03.00.70";
        example = "v02.02.01.60";
        description = "Upstream tag to build.";
      };

      useClang = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Build with clang instead of GCC.";
      };

      jpegVersion = lib.mkOption {
        type = with lib.types; nullOr (enum [6 7 8]);
        default = null;
        description = ''
          Sets -DJPEG_VERSION to match your GStreamer libjpeg (6/7/8).
          Only affects P1P live view; safe to leave null.
        '';
      };
    };

    # Optionally add common GStreamer plugins system-wide, just in case.
    addGStreamerRuntime = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Add common GStreamer plugin sets to the system profile.";
    };

    # Add serial access group for USB tethers (rare for Bambu, but harmless).
    grantDialout = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Add all users to the dialout group for serial access.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [cfg.package]
      ++ lib.optionals cfg.addGStreamerRuntime [
        pkgs.gstreamer
        pkgs.gst_all_1.gst-plugins-base
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
        pkgs.gst_all_1.gst-plugins-ugly
        pkgs.gst_all_1.gst-libav
      ];

    users.users =
      lib.mkIf cfg.grantDialout
      (lib.mapAttrs (_: u: u // {extraGroups = (u.extraGroups or []) ++ ["dialout"];})
        config.users.users);
  };
}
