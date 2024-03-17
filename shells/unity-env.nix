{pkgs}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    unityhub
  ];
}
