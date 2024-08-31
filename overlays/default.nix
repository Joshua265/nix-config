# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    xwayland = prev.xwayland.overrideAttrs (o: {
      patches =
        (o.patches or [])
        ++ [
        ];
    });
    kwin = prev.kwin.overrideAttrs (o: {
      patches =
        (o.patches or [])
        ++ [
          ./patches/kwin.patch
        ];
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  personal-packages = final: _prev: {
    personal = import inputs.nixpkgs-personal {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
