{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  nativeBuildInputs = [
    (pkgs.python310.withPackages (with python-pkgs; [
      pip
      setuptools
      pandas
      requests
      beautifulsoup4
      numpy
      scipy
      matplotlib
      pydantic
      flask
      flask-cors
      tensorflowWithCuda
      torchWithCuda
    ]))
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.cudatoolkit_10_1}/lib:${pkgs.cudnn_cudatoolkit_10_1}/lib:${pkgs.cudatoolkit_10_1.lib}/lib:$LD_LIBRARY_PATH
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.7/site-packages:$PYTHONPATH"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}
