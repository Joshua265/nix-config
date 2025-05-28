{pkgs, ...}: {
  services.fprintd = {
    enable = true;
    # On many Framework 12-/13-gen machines *no* TOD driver is needed.
    # If enrol fails with “No devices available” add the Goodix TOD:
    # tod.enable = true;
    # tod.driver = pkgs.libfprint-2-tod1-goodix;
  };
  security.pam.services.login.fprintAuth = true;
}
