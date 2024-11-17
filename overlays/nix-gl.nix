{nixGL, ...}: let
  nixGLOverlay = final: prev: let
    inherit (prev.lib or final.lib) filter head replaceStrings genAttrs pipe getBin getName attrNames;
    inherit (builtins) match readDir;
    wrapWithNixGL = wrapper: package: let
      getBinFiles = pkg:
        pipe "${getBin pkg}/bin" [
          readDir
          attrNames
          (filter (n: match "^\\..*" n == null))
        ];

      wrapperBin = pipe wrapper [
        getBinFiles
        (filter (n: n == (getName wrapper)))
        head
        (x: "${wrapper}/bin/${x}")
      ];

      binFiles = getBinFiles package;
      wrapBin = name:
        final.writeShellScriptBin name ''
          exec ${wrapperBin} ${package}/bin/${name} "$@"
        '';
    in
      final.symlinkJoin {
        name = "${package.name}-nixgl";
        paths = (map wrapBin binFiles) ++ [package];
      };

    wrappers = let
      replacePrefix =
        replaceStrings ["wrapWithNixGL"] ["nixGL"];
    in
      genAttrs [
        "wrapWithNixGLNvidia"
        "wrapWithNixGLIntel"
        "wrapWithNixGLDefault"
      ]
      (name: wrapWithNixGL final.${replacePrefix name});
  in
    {
      inherit (nixGL) nixGLNvidia nixGLIntel nixGLDefault;
      inherit wrapWithNixGL;
    }
    // wrappers;
in
  nixGLOverlay
