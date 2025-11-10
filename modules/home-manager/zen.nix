{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.zen-browser = {
    enable = true;

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };

    nativeMessagingHosts = [pkgs.firefoxpwa];

    # Optional: declarative containers + spaces (IDs must be UUIDv4)
    profiles.default = {
      containersForce = true;
      containers = {
        Personal = {
          color = "purple";
          icon = "fingerprint";
          id = 1;
        };
        Work = {
          color = "blue";
          icon = "briefcase";
          id = 2;
        };
      };

      spacesForce = true;
      spaces = let
        c = config.programs.zen-browser.profiles.default.containers;
      in {
        "Work" = {
          id = "cdd10fab-4fc5-494b-9041-325e5759195b";
          container = c.Work.id;
          position = 2000;
        };
      };

      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        keepassxc-browser
        zotero-connector
        windscribe
        adblocker-ultimate
        clearurls
        dark-mode-webextension
      ];
    };
  };

  xdg.mimeApps = let
    value = let
      zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta; # or twilight
    in
      zen-browser.meta.desktopFileName;

    associations = builtins.listToAttrs (map (name: {
        inherit name value;
      }) [
        "application/x-extension-shtml"
        "application/x-extension-xhtml"
        "application/x-extension-html"
        "application/x-extension-xht"
        "application/x-extension-htm"
        "x-scheme-handler/unknown"
        "x-scheme-handler/mailto"
        "x-scheme-handler/chrome"
        "x-scheme-handler/about"
        "x-scheme-handler/https"
        "x-scheme-handler/http"
        "application/xhtml+xml"
        "application/json"
        "text/plain"
        "text/html"
      ]);
  in {
    associations.added = associations;
    defaultApplications = associations;
  };
}
