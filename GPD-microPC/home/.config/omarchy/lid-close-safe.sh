#!/bin/bash

# Lid-close handler (mirror desktop mode).
#
# With a TV connected and mirroring, closing the lid must NOT disrupt anything:
# the mirror stays active and the internal panel stays on (desktop mode on the
# TV keeps working). Suspension is already prevented by lid-external-inhibit
# while an external monitor is present.
#
# Without an active mirror (no external display), fall back to Omarchy's normal
# clamshell behaviour so the laptop suspends / behaves as expected when alone.

MIRROR_FLAG="$HOME/.local/state/omarchy/toggles/hypr/internal-monitor-mirror.lua"

if [[ -f $MIRROR_FLAG ]]; then
  exit 0
fi

exec omarchy-hyprland-monitor-clamshell
