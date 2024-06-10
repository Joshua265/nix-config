{
  config,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.ardour
    pkgs.distrho
    pkgs.helm
    # Include other plugins here as they are added
  ];

  # Set environment variables for plugin paths if necessary
  home.sessionVariables = {
    VST_PATH = "${pkgs.distrho}/lib/vst:${pkgs.helm}/lib/vst";
    # Add other plugin paths here
  };

  # Optionally, you can create a directory for custom plugins
  # home.file = {
  #   ".vst_plugins" = {
  #     source = ./vst_plugins;
  #   };
  # };
}
