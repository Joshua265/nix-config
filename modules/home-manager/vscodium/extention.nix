{ pkgs, ... }:

let
  packagedExtensions = with pkgs.vscode-extensions; [
    davidanson.vscode-markdownlint
  ];
  marketplaceExtensions = (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "flake8";
      publisher = "ms-python";
      version = "2023.6.0";
      sha256 = "Hk7rioPvrxV0zMbwdighBAlGZ43rN4DLztTyiHqO6o4=";
    }
  ])
in
marketplaceExtensions ++ packagedExtensions