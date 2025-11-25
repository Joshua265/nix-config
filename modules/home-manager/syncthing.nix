{
  config,
  pkgs,
  ...
}: {
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = true;

    settings = {
      folders = {
        "remarkable-p2p" = {
          path = "${config.home.homeDirectory}/remarkable-p2p";
          type = "sendreceive";
          fsWatcherEnabled = true;
        };
      };
    };
  };
}
