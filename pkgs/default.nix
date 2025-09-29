# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, youtube-transcribe-flake, ...}: {
  # example = pkgs.callPackage ./example { };
  # zed-editor = pkgs.callPackage ./zed-editor {};
  osm2world = pkgs.callPackage ./osm2world {};
  youtube-transcribe = youtube-transcribe-flake.packages.${pkgs.system}.default;
}
