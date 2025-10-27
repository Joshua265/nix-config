# This file defines overlays
{
  inputs,
  system,
  ...
}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev:
    import ../pkgs {
      pkgs = final;
      youtube-transcribe-flake = inputs.youtube-transcribe-flake;
    };

  nixGLOverlay = import ./nix-gl.nix {
    nixGL = inputs.nixGL.packages.${system};
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    unstable =
      prev.unstable
      // {
        bambu-studio = prev.unstable.bambu-studio.overrideAttrs (old: let
          newVersion = "02.03.00.70";
        in {
          version = newVersion;
          src = prev.fetchFromGitHub {
            owner = "bambulab";
            repo = "BambuStudio";
            rev = "v${newVersion}";
            hash = "sha256-2duNeSBi2WvsAUxkzTbKH+SiliNovc7LVICTzgQkrN8="; # ggf. mit lib.fakeSha256 ermitteln
          };

          # falls nötig: nativeBuildInputs erweitern, nicht buildInputs
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [prev.cmake prev.pkg-config];

          postPatch =
            (old.postPatch or "")
            + ''
              # Entferne fälschliche cereal-Links (header-only).
              grep -RIl "target_link_libraries" . | while read -r f; do
                sed -i \
                  -e 's/\bcereal::cereal\b//g' \
                  -e 's/[[:space:]]\bcereal\b//g' \
                  "$f"
              done
            '';

          postInstall =
            (old.postInstall or "")
            + ''
              wrapProgram $out/bin/bambu-studio --set GBM_BACKEND dri
            '';

          cmakeFlags =
            (old.cmakeFlags or [])
            ++ [
              "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
            ];
        });
      };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  legacy-packages = final: _prev: {
    legacy = import inputs.nixpkgs-legacy {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
