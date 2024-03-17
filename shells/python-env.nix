{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  nativeBuildInputs = [
    (pkgs.python310.withPackages (python-pkgs: [
      python-pkgs.pandas
      python-pkgs.requests
      python-pkgs.beautifulsoup4
      python-pkgs.numpy
      python-pkgs.scipy
      python-pkgs.matplotlib
      python-pkgs.pytorch
      python-pkgs.pydantic
      python-pkgs.flask
      python-pkgs.flask-cors
    ]))
  ];
}
