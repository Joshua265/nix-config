{pkgs, ...}: {
  # Enable Display Manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    greetd.tuigreet
    greetd.regreet
    libsecret
  ];

  # unlock GPG keyring on login
  programs.ssh.startAgent = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
