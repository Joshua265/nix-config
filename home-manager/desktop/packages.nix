{pkgs, ...}: {
  home.packages = with pkgs; [
    # 2D
    # personal.comfyui # -cuda # comfyui-cuda
    # personal.comfyui-custom-nodes # not sure how to install, seems to be an override

    # (pkgs.symlinkJoin {
    #   name = "FreeCAD";
    #   paths = [pkgs.freecad-wayland];
    #   buildInputs = [pkgs.makeWrapper];
    #   postBuild = ''
    #     wrapProgram $out/bin/FreeCAD \
    #     --set __GLX_VENDOR_LIBRARY_NAME mesa \
    #     --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json
    #   '';
    #   meta.mainProgram = "FreeCAD";
    # })
    freecad

    xorg.xrandr

    # matlab

    # coding
    # vscodium from modules
    unstable.zed-editor
    unstable.terraform

    # dart
    flutter
    android-tools
    android-studio

    extra-cmake-modules

    # gaming
    wine
    adwaita-icon-theme

    # flatpak
    # gnome.gnome-software
    unstable.lutris
  ];
}
