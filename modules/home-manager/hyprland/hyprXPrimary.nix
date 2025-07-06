{
  lib,
  fetchFromGitHub,
  cmake,
  hyprland, # comes from inputs.hyprland
  hyprlandPlugins, # gives us mkHyprlandPlugin
}:
hyprlandPlugins.mkHyprlandPlugin hyprland {
  pluginName = "hyprXPrimary";
  version = "0.1.0"; # arbitrary – use commit date if you like
  src = fetchFromGitHub {
    owner = "zakk4223";
    repo = "hyprXPrimary";
    rev = "676ee91"; # pin a commit!
    hash = "sha256-hm+Nsp7BGhgUvRvHnsxqO48igxrMLzsH+3/4njrluUQ="; # run nix-prefetch-github once
  };

  postPatch = ''
    cat > CMakeLists.txt <<'EOF'
    cmake_minimum_required(VERSION 3.27)
    project(hyprXPrimary VERSION 0.1 LANGUAGES CXX)
    set(CMAKE_CXX_STANDARD 23)
    file(GLOB SRC "*.cpp")
    add_library(hyprXPrimary SHARED ''${SRC})
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(deps REQUIRED IMPORTED_TARGET
        hyprland xcb-randr pixman-1 libdrm)
    target_link_libraries(hyprXPrimary PRIVATE PkgConfig::deps)
    install(TARGETS hyprXPrimary)
    EOF
  '';
  nativeBuildInputs = [cmake];
  meta = {
    description = "Set a primary X11 display for Hyprland";
    homepage = "https://github.com/zakk4223/hyprXPrimary";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
}
