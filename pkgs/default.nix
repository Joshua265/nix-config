# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  # example = pkgs.callPackage ./example { };
  # zed-editor = pkgs.callPackage ./zed-editor {};
  freecad-local = pkgs.callPackage ./freecad-local {};
}
