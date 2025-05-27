set -e
git diff -U0 *.nix
echo "NixOS Rebuilding..."

sudo nixos-rebuild switch --flake .#nixos-desktop "$@" &> nixos-switch-desktop.log || (
  grep --color error nixos-switch-desktop.log && false
)

gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"
git push
