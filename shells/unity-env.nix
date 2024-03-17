{pkgs}:
pkgs.mkShell {
  packages = with pkgs; [
    unityhub
  ];
}
