{pkgs, ...}: let
  auto-brightness = pkgs.writeScriptBin "auto-brightness" ''
    #!${pkgs.stdenv.shell}

    monitor-sensor | while read -r line; do
        if echo "$line" | grep -q "Light changed"; then
          LUX=$(echo "$line" | awk '{print $NF}')
          if [ "$LUX" -lt 100 ]; then
            echo "brightness: 0.2"
          elif [ "$LUX" -lt 200 ]; then
            echo "brightness: 0.5"
          elif [ "$LUX" -lt 300 ]; then
            echo "brightness: 0.7"
          elif [ "$LUX" -lt 400 ]; then
            echo "brightness: 0.8"
          elif [ "$LUX" -lt 500 ]; then
            echo "brightness: 0.9"
          else
            echo "brightness: 1.0"
          fi
  '';
in {
  environment.systemPackages = [auto-brightness];
}
