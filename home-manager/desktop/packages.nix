{pkgs, ...}: {
  home.packages = with pkgs; [
    # 3D
    blender
    freecad
    cura

    # 2D
    # personal.comfyui # -cuda # comfyui-cuda
    # personal.comfyui-custom-nodes # not sure how to install, seems to be an override

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
    gnome3.adwaita-icon-theme
    steam
    (steam.override {
      extraPkgs = pkgs: [monado openhmd];
    })
    .run
    flatpak
    gnome.gnome-software
    lutris
  ];
}
