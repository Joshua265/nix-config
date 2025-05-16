set -e
git diff -U0 *.nix
echo "NixOS Rebuilding..."

sudo nixos-rebuild switch --flake .#nixos-framework "$@" &> nixos-switch-framework.log || (
  grep --color error nixos-switch-framework.log && false
)

gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"
git push
