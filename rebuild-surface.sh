set -e
# pushd ~/dotfiles/nixos/
# alejandra . &>/dev/null
git diff -U0 *.nix
echo "NixOS Rebuilding..."
sudo nixos-rebuild switch  --flake .#nixos-surface &>nixos-switch-surface.log || (
 cat nixos-switch-surface.log | grep --color error && false)
gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"
# popd
