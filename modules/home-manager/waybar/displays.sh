#!/usr/bin/env bash
set -euo pipefail

menu_cmd() { wofi -d -i "$@"; }   # swap for: fuzzel --dmenu, tofi --prompt …
mon_json() { hyprctl -j monitors; }

active_names() { mon_json | jq -r '.[].name'; }
internal_name() { mon_json | jq -r '.[] | select(.name|test("^(eDP|LVDS|DSI)")) | .name' | head -n1 || true; }

status() {
  local n; n=$(active_names | wc -l | tr -d ' ')
  # Waybar custom module expects JSON when return-type=json
  printf '{"text":"󰍹","tooltip":"%s display(s)"}\n' "$n"
}

pick_output() {
  local prompt="$1"
  active_names | menu_cmd -p "$prompt"
}

extend_side() {
  # $1: side "left"|"right", $2: internal name
  local side="$1" int="$2"
  local ext; ext=$(active_names | grep -v "^$int$" | menu_cmd -p "Extend which output?" || true)
  [ -z "${ext:-}" ] && exit 0
  # Place internal at origin, external auto-left/right of it
  hyprctl --batch "keyword monitor $int,preferred,0x0,1 ; keyword monitor $ext,preferred,auto-$side,1" >/dev/null
}

mirror_to_ext() {
  # $1: internal name
  local int="$1"
  local ext; ext=$(active_names | grep -v "^$int$" | menu_cmd -p "Mirror to which output?" || true)
  [ -z "${ext:-}" ] && exit 0
  # Mirror external from internal; resolution follows the source (internal)
  hyprctl --batch "keyword monitor $int,preferred,0x0,1 ; keyword monitor $ext,preferred,auto,1,mirror,$int" >/dev/null
}

solo_internal() {
  local int="$1"
  for m in $(active_names); do
    if [ "$m" = "$int" ]; then
      hyprctl keyword monitor "$m,preferred,0x0,1" >/dev/null
    else
      hyprctl keyword monitor "$m,disable" >/dev/null
    fi
  done
}

solo_external() {
  local int="$1"
  for m in $(active_names); do
    if [ "$m" = "$int" ]; then
      hyprctl keyword monitor "$m,disable" >/dev/null
    else
      hyprctl keyword monitor "$m,preferred,auto,1" >/dev/null
    fi
  done
}

list_modes() {
  # $1: output name like eDP-1 / HDMI-A-1 / DP-1
  local out="$1"
  local path; path=$(ls -d /sys/class/drm/*-"$out" 2>/dev/null | head -n1 || true)
  if [ -n "${path:-}" ] && [ -f "$path/modes" ]; then
    sort -u "$path/modes"
  else
    echo "preferred"
  fi
}

set_resolution() {
  local out; out=$(pick_output "Which output?" || true)
  [ -z "${out:-}" ] && exit 0
  local res; res=$(list_modes "$out" | menu_cmd -p "Mode for $out" || true)
  [ -z "${res:-}" ] && exit 0
  # Keep current position/scale to avoid layout jumps
  read -r x y scale <<<"$(mon_json | jq -r '.[]|select(.name=="'"$out"'")|"\(.x) \(.y) \(.scale)"')"
  hyprctl keyword monitor "$out,$res,${x}x${y},$scale" >/dev/null
}

menu_root() {
  local int; int=$(internal_name || true)
  local items=$'Extend →\nExtend ←\nMirror (internal → external)\nInternal only\nExternal only\nSet resolution…'
  local choice; choice=$(printf "%s" "$items" | menu_cmd -p "Displays" || true)
  case "${choice:-}" in
    "Extend →") extend_side right "${int:-}";;
    "Extend ←") extend_side left  "${int:-}";;
    "Mirror (internal → external)") [ -n "${int:-}" ] && mirror_to_ext "$int" || :
      ;;
    "Internal only") [ -n "${int:-}" ] && solo_internal "$int" || :
      ;;
    "External only") [ -n "${int:-}" ] && solo_external "$int" || :
      ;;
    "Set resolution…") set_resolution;;
    *) :;;
  esac
}

case "${1:-status}" in
  status) status;;
  menu)   menu_root;;
  *) echo "usage: $0 [status|menu]" >&2; exit 2;;
esac
