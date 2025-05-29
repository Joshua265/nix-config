{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    ardour
    distrho-ports
    helm
    # Include other plugins here as they are added

    # other music software
    openutau
  ];
}
