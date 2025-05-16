{pkgs, ...}: {
  # Enable Display Manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland \
        --theme border=magenta;text=cyan;prompt=cyan;time=purple;action=blue;button=cyan;container=black;input=purple";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    greetd.tuigreet
    greetd.regreet
    libsecret
  ];
}
