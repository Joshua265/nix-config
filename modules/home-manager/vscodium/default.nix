# Code adapted from
# https://github.com/carlthome/dotfiles/tree/66e806a7560aeaaf77b706e5d81a2c2b72f60900/modules/home-manager/vscode
{
  config,
  pkgs,
  lib,
  ...
}: let
  settings-directory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "$HOME/Library/Application Support/VSCodium/User"
    else "$HOME/.config/VSCodium/User";
  userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
  keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
in {
  programs.vscode = {
    inherit userSettings keybindings;
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      github.copilot
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
      pkief.material-icon-theme
      redhat.vscode-yaml
      rust-lang.rust-analyzer
      stkb.rewrap
      tamasfe.even-better-toml
      tomoki1207.pdf
      twxs.cmake
      kamadorueda.alejandra
      dart-code.flutter
      enkia.tokyo-night
    ];
  };

  # Copy VS Code settings into the default location as a mutable copy.
  home.activation = {
    beforeCheckLinkTargets = {
      after = [];
      before = ["checkLinkTargets"];
      data = ''
        if [ -f "${settings-directory}/settings.json" ]; then
          rm "${settings-directory}/settings.json"
        fi
        if [ -f "${settings-directory}/keybindings.json" ]; then
          rm "${settings-directory}/keybindings.json"
        fi
      '';
    };

    afterWriteBoundary = {
      after = ["writeBoundary"];
      before = [];
      data = ''
        cat ${(pkgs.formats.json {}).generate "settings.json" userSettings} > "${settings-directory}/settings.json"
        cat ${(pkgs.formats.json {}).generate "keybindings.json" keybindings} > "${settings-directory}/keybindings.json"
      '';
    };
  };

  # vscode server
  imports = [
    ./development.nix
    # pkgs.vscode-server-src

    "${fetchTarball {
      url = "https://github.com/nix-community/nixos-vscode-server/tarball/master";
      sha256 = "sha256:1mrc6a1qjixaqkv1zqphgnjjcz9jpsdfs1vq45l1pszs9lbiqfvd";
    }}/modules/vscode-server/home.nix"
  ];

  services.vscode-server = {
    enable = true;
    #useFhsNodeEnvironment = false;
  };
}
