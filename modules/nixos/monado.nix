{pkgs, ...}: {
  # Monado (NixOS module)
  services.monado = {
    enable = true; # creates a *user* systemd unit managed by NixOS
    defaultRuntime = true; # set Monado as system OpenXR runtime
    package = pkgs.unstable.monado; # overlay set in overlays
  };

  # Extra environment for the user unit that the Monado module provides
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0";
    XRT_DEBUG_GUI = "0";
  };
}
