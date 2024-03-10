{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      github.copilot
      github.github-vscode-theme
      github.vscode-github-actions
      github.vscode-pull-request-github
      gitlab.gitlab-workflow
      jnoortheen.nix-ide
      mikestead.dotenv
      ms-azuretools.vscode-docker
      ms-kubernetes-tools.vscode-kubernetes-tools
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
      redhat.vscode-yaml
      rust-lang.rust-analyzer
      stkb.rewrap
      svelte.svelte-vscode
      tamasfe.even-better-toml
      tomoki1207.pdf
      twxs.cmake
    ];
  };
}
