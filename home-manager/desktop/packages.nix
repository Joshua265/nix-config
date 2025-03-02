{pkgs, ...}: {
  home.packages = with pkgs; [
    # 2D
    # personal.comfyui # -cuda # comfyui-cuda
    # personal.comfyui-custom-nodes # not sure how to install, seems to be an override

    matlab

    # coding
    # vscodium from modules
    unstable.zed-editor
    unstable.terraform

    # dart
    flutter
    android-tools
    android-studio

    ollama

    extra-cmake-modules

    # gaming
    openhmd
    monado
    openvr
    wine
    adwaita-icon-theme
    steam
    (steam.override {
      extraPkgs = pkgs: [monado openhmd];
    })
    .run
    # flatpak
    # gnome.gnome-software
    lutris
  ];
}
