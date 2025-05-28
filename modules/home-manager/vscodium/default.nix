# Code adapted from
# https://github.com/carlthome/dotfiles/tree/66e806a7560aeaaf77b706e5d81a2c2b72f60900/modules/home-manager/vscode
{
  config,
  pkgs,
  lib,
  ...
}: let
  settings-directory = "${config.home.homeDirectory}/.config/VSCodium/User";
in {
  home.packages = with pkgs; [
    nil
  ];
  programs.direnv.enable = true;
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions;
      [
        catppuccin.catppuccin-vsc-icons
        carrie999.cyberpunk-2020
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        github.copilot
        github.vscode-github-actions
        github.vscode-pull-request-github
        golang.go
        jnoortheen.nix-ide
        llvm-vs-code-extensions.vscode-clangd
        mikestead.dotenv
        ms-azuretools.vscode-docker
        ms-python.black-formatter
        ms-python.isort
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow
        ms-toolsai.jupyter-renderers
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vscode.cmake-tools
        ms-vscode.makefile-tools
        ms-vscode.live-server
        pkief.material-icon-theme
        mechatroner.rainbow-csv
        redhat.vscode-yaml
        rust-lang.rust-analyzer
        stkb.rewrap
        tamasfe.even-better-toml
        tomoki1207.pdf
        twxs.cmake
        kamadorueda.alejandra
        dart-code.flutter
        enkia.tokyo-night
        arrterian.nix-env-selector
        mkhl.direnv
        hashicorp.terraform
        james-yu.latex-workshop
        usernamehw.errorlens
        vscodevim.vim
        yoavbls.pretty-ts-errors
        ziglang.vscode-zig
      ]
      ++ [
        pkgs.unstable.vscode-extensions.geequlim.godot-tools
        pkgs.unstable.vscode-extensions.rooveterinaryinc.roo-cline
      ];
  };

  # VIM Settings
  home.file = {
    "${settings-directory}/settings.json".source = ./settings.json;
    "${settings-directory}/keybindings.json".source = ./keybindings.json;
  };

  # vscode server
  imports = [
    ./development.nix
    # pkgs.vscode-server-src

    "${fetchTarball {
      url = "https://github.com/nix-community/nixos-vscode-server/tarball/master";
      sha256 = "sha256:09j4kvsxw1d5dvnhbsgih0icbrxqv90nzf0b589rb5z6gnzwjnqf";
    }}/modules/vscode-server/home.nix"
  ];

  services.vscode-server = {
    enable = true;
    #useFhsNodeEnvironment = false;
  };
}
