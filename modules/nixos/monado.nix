{pkgs, ...}: {
  # Monado (NixOS module)

  environment.systemPackages = with pkgs; [
    basalt-monado # Basalt fork for Monado (provides libbasalt.so)
  ];

  services.monado = {
    enable = true; # creates a *user* systemd unit managed by NixOS
    defaultRuntime = true; # set Monado as system OpenXR runtime
    package = pkgs.monado; # use nixpkgs-xr monado
  };

  # Extra environment for the user unit that the Monado module provides
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0";
    XRT_DEBUG_GUI = "0";
    VIT_SYSTEM_LIBRARY_PATH = "${pkgs.basalt-monado}/lib/libbasalt.so";
  };
}
