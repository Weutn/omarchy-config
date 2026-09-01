#!/bin/bash

# Toggle Omarchy's idle.lock based on whether an external monitor is connected.
#
# Why: when an external monitor is present the Omarchy lock screen (a layer
# surface) triggers the upstream Hyprland crash in CInputManager::refocusLastWindow
# (see discussions #11708 / cursor fixes #13574). Keeping the idle "lock" far
# in the future means the Omarchy screensaver stays up forever and the lock (and
# the crash) never fires while a TV is attached. In nomad mode (no external
# display) the stock idle/lock behaviour is restored so the machine can sleep
# and save battery.
#
# Long lock values must be finite (secondsFromConfig rejects non-finite numbers
# and falls back to the default), so we use a day-ish value instead of infinity.

SHELL_JSON="$HOME/.config/omarchy/shell.json"
LOCK_NOMAD=300      # seconds until the lock/suspend cycle in nomad mode (stock)
LOCK_EXTERNAL=86400 # 24h: effectively never locks while a TV is attached
SCREENSAVER=150

log() { echo "$(date '+%H:%M:%S') $*"; }

set_idle_lock() {
  local value="$1"

  if [[ ! -f $SHELL_JSON ]]; then
    log "shell.json missing; skipping idle lock update"
    return
  fi

  if ! command -v jq >/dev/null 2>&1; then
    log "jq missing; skipping idle lock update"
    return
  fi

  local current
  current=$(jq -r '.idle.lock // empty' "$SHELL_JSON" 2>/dev/null)
  if [[ "$current" == "$value" ]]; then
    return
  fi

  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' RETURN
  if ! jq --argjson lock "$value" --argjson ss "$SCREENSAVER" \
      '.idle.lock = $lock | .idle.screensaver = $ss' "$SHELL_JSON" >"$tmp"; then
    log "failed to rewrite shell.json"
    return
  fi
  mv "$tmp" "$SHELL_JSON"
  chmod 644 "$SHELL_JSON"
  log "idle.lock set to $value (external monitors: $([ "$value" = "$LOCK_EXTERNAL" ] && echo yes || echo no)); restarting shell"
  omarchy restart shell >/dev/null 2>&1 || true
}

apply_idle_by_external() {
  if omarchy hw external monitors 2>/dev/null; then
    set_idle_lock "$LOCK_EXTERNAL"
  else
    set_idle_lock "$LOCK_NOMAD"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  apply_idle_by_external
fi
