{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # nix deploy
    colmena

    # for vscode-server..
    openssl
    pkg-config

    # platforms
    gh
    doctl

    # go tooling
    go
    gopls

    # rust tooling
    rustup
  ];
}
