# Code adapted from
# https://github.com/carlthome/dotfiles/tree/66e806a7560aeaaf77b706e5d81a2c2b72f60900/modules/home-manager/vscode
{
  config,
  pkgs,
  lib,
  ...
}: let
  settings-directory = "${config.home.homeDirectory}/.config/VSCodium/User";
  # userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
  # keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
in {
  home.packages = with pkgs; [
    nil
  ];
  programs.direnv.enable = true;
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.unstable.vscodium;
    extensions = with pkgs.unstable.vscode-extensions; [
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
      ms-vscode.live-server
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
      arrterian.nix-env-selector
      mkhl.direnv
      hashicorp.terraform
      james-yu.latex-workshop
    ];
  };

  # Standard Settings
  # home.file = {
  #   "${settings-directory}/settings.json".source = ./settings.json;
  #   "${settings-directory}/keybindings.json".source = ./keybindings.json;
  # };

  # VIM Settings
  home.file = {
    "${settings-directory}/settings.json".source = ./vim_settings/settings.json;
    "${settings-directory}/keybindings.json".source = ./vim_settings/keybindings.json;
  };

  # Copy VS Code settings into the default location as a mutable copy.
  # home.activation = {
  #   beforeCheckLinkTargets = {
  #     after = [];
  #     before = ["checkLinkTargets"];
  #     data = ''
  #       if [ -f "${settings-directory}/settings.json" ]; then
  #         rm "${settings-directory}/settings.json"
  #       fi
  #       if [ -f "${settings-directory}/keybindings.json" ]; then
  #         rm "${settings-directory}/keybindings.json"
  #       fi
  #     '';
  #   };

  #   afterWriteBoundary = {
  #     after = ["writeBoundary"];
  #     before = [];
  #     data = ''
  #       cat ${(pkgs.formats.json {}).generate "settings.json" userSettings} > "${settings-directory}/settings.json"
  #       cat ${(pkgs.formats.json {}).generate "keybindings.json" keybindings} > "${settings-directory}/keybindings.json"
  #     '';
  #   };
  # };

  # vscode server
  imports = [
    ./development.nix
    # pkgs.vscode-server-src

    "${fetchTarball {
      url = "https://github.com/nix-community/nixos-vscode-server/tarball/master";
      sha256 = "sha256:1rq8mrlmbzpcbv9ys0x88alw30ks70jlmvnfr2j8v830yy5wvw7h";
    }}/modules/vscode-server/home.nix"
  ];

  services.vscode-server = {
    enable = true;
    #useFhsNodeEnvironment = false;
  };
}
