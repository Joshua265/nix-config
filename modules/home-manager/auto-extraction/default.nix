{ config, pkgs, ... }:

{
  # Add inotify-tools as part of the system packages
  home.packages = with pkgs; [
    inotify-tools
    unzip
  ];

  home.file."${config.home.homeDirectory}/.config/scripts/auto_extract_zip.sh".source = ./auto_extract_zip.sh;

  # Define a systemd service for automatic extraction of zip files
  systemd.user.services.autoExtractZip = {
    description = "Automatically extract ZIP files from Downloads";
    wantedBy = [ "default.target" ];

    # Path to the script
    serviceConfig = {
      ExecStart = "${config.home.homeDirectory}/.config/scripts/auto_extract_zip.sh";
      Restart = "on-failure";  # Restart the script if it crashes
    };

    # Ensure the script starts after the user logs in
    install = {
      wantedBy = [ "default.target" ];
    };
  };

  # Enable the systemd service
  home.activation.enableSystemdUser = true;
}

