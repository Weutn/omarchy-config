#!/bin/bash

# Open a 4-pane system dashboard on workspace 2 at every session start:
#   btop (main monitor, largest) / fastfetch (system info, 2nd) /
#   s-tui (CPU frequency & temperature) / cbonsai (aesthetic bonsai).
#
# fastfetch uses ~/.config/fastfetch/config.jsonc: the full Omarchy info with
# the full-size Omarchy logo, and its foot window runs at a smaller font
# (size=5, "zoom out") so logo + all info fit the pane. The font is capped by
# the pane height (29 data lines); the width is filled by the full logo.
#
# Use a "--" separator to pass foot options (before) separately from the
# command to run (after).
#
# Edit FINAL_WS to control where you land after the dashboard opens:
# "1" starts you on the (empty) home workspace; the dashboard stays on ws 2.
# "2" drops you straight into the dashboard.

FINAL_WS="1"
APPS=(omarchy-dash-btop omarchy-dash-fastfetch omarchy-dash-stui omarchy-dash-bonsai)

# Nothing to do if Hyprland isn't up yet.
hyprctl monitors -j >/dev/null 2>&1 || exit 0

# Skip if the dashboard is already open (second run or user kept it).
for app in "${APPS[@]}"; do
  hyprctl clients -j 2>/dev/null | jq -e --arg a "$app" '.[]|select(.class==$a)' >/dev/null 2>&1 && exit 0
done

# Launch a TUI in its own foot window and wait until it actually maps, so the
# windows tile in this exact order (btop largest, fastfetch second, then a
# tall pair of smaller panes on the right) every time. If a "--" is given, the
# arguments before it are passed to foot itself and the rest to the command.
launch_wait() {
  local class="$1"
  shift
  local -a args=( "$@" )
  local -a footopts=() cmd=()
  local i=0 sep=-1 n=${#args[@]}
  for (( i=0; i<n; i++ )); do
    [[ ${args[i]} == -- ]] && { sep=$i; break; }
  done
  if [[ $sep -lt 0 ]]; then
    cmd=( "${args[@]}" )
  else
    footopts=( "${args[@]:0:sep}" )
    cmd=( "${args[@]:sep+1}" )
  fi
  setsid uwsm-app -- foot -a "$class" "${footopts[@]}" -e "${cmd[@]}" >/dev/null 2>&1 &
  for _ in $(seq 1 50); do
    hyprctl clients -j 2>/dev/null | jq -e --arg a "$class" '.[]|select(.class==$a)' >/dev/null 2>&1 && return 0
    sleep 0.2
  done
  return 1
}

hyprctl dispatch 'hl.dsp.focus({ workspace = "2" })'

launch_wait omarchy-dash-btop      btop
launch_wait omarchy-dash-fastfetch -f 'monospace:size=5' -- fastfetch --watch 30
launch_wait omarchy-dash-stui      s-tui
launch_wait omarchy-dash-bonsai    cbonsai -i

sleep 1
if [[ -n ${FINAL_WS:-} ]]; then
  hyprctl dispatch "hl.dsp.focus({ workspace = \"$FINAL_WS\" })"
fi