{ pkgs, ... }:

let
  packagedExtensions = with pkgs.vscode-extensions; [
    davidanson.vscode-markdownlint
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    github.copilot
    github.github-vscode-theme
    github.vscode-github-actions
    github.vscode-pull-request-github
    jnoortheen.nix-ide
    mikestead.dotenv
    ms-azuretools.vscode-docker
    ms-python.black-formatter
    ms-python.isort
    ms-python.python
    ms-python.vscode-pylance
    ms-toolsai.jupyter
    ms-toolsai.vscode-jupyter-slideshow
    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vscode.cmake-tools
    ms-vscode.makefile-tools
    njpwerner.autodocstring
    pkief.material-icon-theme
    rust-lang.rust-analyzer
    tamasfe.even-better-toml
    tomoki1207.pdf
  ];
  marketplaceExtensions = (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "flake8";
      publisher = "ms-python";
      version = "2023.6.0";
      sha256 = "Hk7rioPvrxV0zMbwdighBAlGZ43rN4DLztTyiHqO6o4=";
    }
    {
      name = "debugpy";
      publisher = "ms-python";
      version = "2023.3.13121011";
      sha256 = "owYUEyQl2FQytApfuI97N4y9p7/dL0lu6EBk/AzSMjw=";
    }
    {
      name = "git-line-blame";
      publisher = "carlthome";
      version = "0.6.1";
      sha256 = "sha256-Jh4DmLEoCsA0lY1ad3jMQRhWXEoXmggAKW8Z9QGYJjY=";
    }
    {
      name = "copilot-chat";
      publisher = "github";
      version = "0.8.0";
      sha256 = "IJ75gqsQj0Ukjlrqevum5AoaeZ5vOfxX/4TceXe+EIg=";
    }
    {
      name = "datawrangler";
      publisher = "ms-toolsai";
      version = "0.26.0";
      sha256 = "sha256-9Diu3mb7VjB4MXWb5+gYnEjXJiAzSww4Ij3VDb4l77w=";
    }
    {
      name = "vscode-dotnet-runtime";
      publisher = "ms-dotnettools";
      version = "2.0.1";
      sha256 = "sha256-tyPHE3YAKDx6SW/qguafe5OmxDKLPfQHXjsDQaGONFg=";
    }
  ])
in
marketplaceExtensions ++ packagedExtensions