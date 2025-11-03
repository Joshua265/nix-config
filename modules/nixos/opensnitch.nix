# configuration.nix (or a module you import)
{
  lib,
  pkgs,
  ...
}: {
  services.opensnitch = {
    enable = true;

    # Optional but recommended: use eBPF monitor (default on recent NixOS)
    settings.ProcMonitorMethod = "ebpf";

    # Two precise allow-rules for Bambu Studio
    rules = {
      # 0) UDP discovery: SSDP/broadcast for finding printers
      "000-allow-bambu-studio-discovery-udp.json" = {
        name = "000-allow-bambu-studio-discovery-udp";
        enabled = true;
        precedence = true; # evaluate early, small perf gain
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              operand = "process.path";
              data = "${lib.getBin pkgs.unstable.bambu-studio}/bin/bambu-studio";
            }
            {
              type = "simple";
              operand = "protocol";
              data = "udp";
            }
            # Ports 1990 and 2021
            {
              type = "regexp";
              operand = "dest.port";
              data = "^(1990|2021)$";
            }
          ];
        };
      };

      # 1) TCP to the printer on your LAN for MQTT/FTPS/FTP passive/video
      "001-allow-bambu-studio-lan-tcp.json" = {
        name = "001-allow-bambu-studio-lan-tcp";
        enabled = true;
        precedence = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              operand = "process.path";
              data = "${lib.getBin pkgs.unstable.bambu-studio}/bin/bambu-studio";
            }
            {
              type = "simple";
              operand = "protocol";
              data = "tcp";
            }
            # limit to your LAN segment
            {
              type = "network";
              operand = "dest.network";
              data = "192.168.100.0/24";
            }
            # 8883, 990, 322, 6000 and the passive range 50000–50100
            {
              type = "regexp";
              operand = "dest.port";
              # 500\d\d matches 50000–50099; add 50100 explicitly
              data = "^(8883|990|322|6000|500\\d\\d|50100)$";
            }
          ];
        };
      };

      # 2) TCP for Spotify (port 57621)
      "002-allow-spotify-57621-tcp.json" = {
        name = "002-allow-spotify-57621-tcp";
        enabled = true;
        precedence = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              operand = "process.path";
              data = "${lib.getBin pkgs.spotify}/bin/spotify";
            }
            {
              type = "simple";
              operand = "protocol";
              data = "tcp";
            }
            {
              type = "simple";
              operand = "dest.port";
              data = "57621";
            }
          ];
        };
      };
    };
  };

  # (Optional) Install the GUI client so rules are visible/editable
  environment.systemPackages = [pkgs.opensnitch-ui];
}
