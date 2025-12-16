{
  config,
  pkgs,
  ...
}: {
  # Blacklist the surfacepro3_button module
  boot.blacklistedKernelModules = ["surfacepro3_button"];

  # Create the custom modprobe configuration
  environment.etc."modprobe.d/surfacepro3.conf".text = ''
    blacklist surfacepro3_button
    install surfacepro3_button /bin/false
  '';

  # services.logind = {
  #   lidSwitch = "ignore";
  #   powerKey = "ignore";
  # };
}
