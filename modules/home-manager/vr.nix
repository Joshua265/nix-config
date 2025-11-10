{
  config,
  pkgs,
  ...
}: {
  # Monado nixos module + override required
  # STEAM start option:
  # PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%

  # OpenXR: per-user override (optional if you set services.monado.defaultRuntime = true)
  xdg.configFile."openxr/1/active_runtime.json".source = "${pkgs.monado}/share/openxr/1/openxr_monado.json";

  # OpenVR: point to OpenComposite (or XRizer) runtime
  xdg.configFile."openvr/openvrpaths.vrpath".text = builtins.toJSON {
    config = ["${config.xdg.dataHome}/Steam/config"];
    external_drivers = null;
    jsonid = "vrpathreg";
    log = ["${config.xdg.dataHome}/Steam/logs"];
    runtime = ["${pkgs.opencomposite}/lib/opencomposite"];
    version = 1;
  };

  # Hand-tracking models (Monado expects these in ~/.local/share/…)
  home.file.".local/share/monado/hand-tracking-models".source = pkgs.fetchgit {
    url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models";
    sha256 = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
    fetchLFS = true;
  };
}
