#!/bin/bash

# Replacements for Omarchy's omarchy-hyprland-monitor-watch (disabled via
# ~/.config/hypr/autostart.lua):
#   1. Inhibit lid-close suspend while an external monitor is connected, so
#      closing the lid with a reflective mirrored display keeps working.
#   2. Recover a "modeless" external monitor (0x0, black screen) — an HDMI sink
#      that was powered on at boot answers with a partial EDID carrying no video
#      modes. A reload re-reads the EDID and brings the mode up.
#   3. Recover a stale mirror when no external display is present.

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
WHO="Omarchy lid-external-inhibit"
TOGGLES_DIR="$HOME/.local/state/omarchy/toggles/hypr"
MIRROR_FLAG="$TOGGLES_DIR/internal-monitor-mirror.lua"
CLAMSHELL_FLAG="$TOGGLES_DIR/internal-monitor-clamshell.lua"
MANUAL_DISABLE_FLAG="$TOGGLES_DIR/internal-monitor-disable.lua"
MIRROR_INTENT="$HOME/.config/omarchy/mirror-intent"
LID_CLOSED="$HOME/.config/omarchy/lid-closed"

INHIBIT_PID=""

log() { echo "$(date '+%H:%M:%S') $*"; }

# ---- lid-close suspend inhibition -------------------------------------------

stop_inhibit() {
  if [[ -n $INHIBIT_PID ]] && kill -0 "$INHIBIT_PID" 2>/dev/null; then
    kill "$INHIBIT_PID" 2>/dev/null
    wait "$INHIBIT_PID" 2>/dev/null
  fi
  INHIBIT_PID=""
}

start_inhibit() {
  systemd-inhibit --what=handle-lid-switch --who="$WHO" --why="External monitor in use" --mode=block sleep infinity &
  INHIBIT_PID=$!
}

apply_inhibit() {
  local external
  if omarchy hw external monitors; then
    external=1
  else
    external=0
  fi

  if (( external )); then
    if [[ -z $INHIBIT_PID ]] || ! kill -0 "$INHIBIT_PID" 2>/dev/null; then
      stop_inhibit
      start_inhibit
    fi
  else
    stop_inhibit
  fi
}

# ---- idle lock avoidance (external monitor) ---------------------------------
# When a TV is attached, Omarchy's lock-layer crash (upstream refocusLastWindow
# bug) triggers on lock; keep idle.lock far in the future so the screensaver
# stays up and never locks. Restore stock idle in nomad mode. The auxiliary
# script restarts the shell only when the value actually changes.

SET_IDLE_BY_EXTERNAL="$HOME/.config/omarchy/set-idle-by-external.sh"
apply_idle_by_external() {
  [[ -x $SET_IDLE_BY_EXTERNAL ]] && "$SET_IDLE_BY_EXTERNAL"
}

# ---- HDMI modeless recovery ------------------------------------------------

# Returns 0 if an enabled non-laptop monitor is modeless (0x0), else 1.
is_external_modeless() {
  hyprctl monitors all -j 2>/dev/null | jq -e \
    'any(.[]; (.name | test("^(eDP|LVDS|DSI)-") | not) and .disabled != true and (.width == 0 or .height == 0))' \
    >/dev/null 2>&1
}

if ! command -v jq >/dev/null 2>&1; then
  is_external_modeless() { return 1; }
fi

recover_modeless() {
  # Guard against a reload storm: only reload if an external is truly modeless
  # and no reload-guard is paused.
  if is_external_modeless && ! omarchy-hyprland-reload-guard paused 2>/dev/null; then
    log "external monitor modeless, reloading"
    hyprctl reload >/dev/null 2>&1 || true
  fi
}

# ---- mirror / clamshell recovery --------------------------------------------

# Whether the user wants mirroring. The intent outlives a disconnect: when the
# external monitor disappears we must clear the live mirror flag (so a lone
# laptop never keeps a stale mirror rule), but we remember the desire so that
# plugging the TV back in brings the mirror back.

mirror_wanted() { [[ -f $MIRROR_FLAG || -f $MIRROR_INTENT ]]; }

# Establish the mirror again if an external monitor is present and wanted.
# Returns without reloading if the mirror is already live or the lid is shut.
restore_mirror() {
  if [[ -f $LID_CLOSED ]]; then
    return
  fi

  if mirror_wanted && omarchy hw external monitors; then
    # Is some non-laptop display already mirroring the laptop panel?
    # Hyprland reports a non-mirrored output as mirrorOf:"none", an active
    # mirror as a small numeric id (e.g. 0). A mirror is live of the value is
    # a number (anything but the string "none").
    if hyprctl monitors all -j 2>/dev/null | jq -e \
         'any(.[]; ((.mirrorOf | type) == "number"))' >/dev/null 2>&1; then
      # Mirror already in force; nothing to do but clear a stale intent.
      rm -f "$MIRROR_INTENT"
      return
    fi

    # Re-create the mirror flag. Contents mirror Omarchy's omarchy-hyprland-
    # monitor-internal-mirror `on`, using the first external connector.
    # Prefer 1080p for the HKC TV: its EDID "preferred" mode is 1366x768, which
    # wastes the panel. Fall back to preferred for any other external display.
    local external mode
    external=$(hyprctl monitors all -j 2>/dev/null | jq -r '.[] | select(.name | test("^(eDP|LVDS|DSI)-") | not).name' | head -n 1)
    if [[ $external == HDMI-* ]]; then
      mode="1920x1080@60"
    else
      mode="preferred"
    fi
    local internal
    internal=$(omarchy-hyprland-monitor-laptop)
    if [[ -n $external && -n $internal ]]; then
      log "external monitor present, (re)establishing mirror ($internal -> $external @ $mode)"
      printf 'hl.monitor({ output = "%s", mode = "%s", position = "auto", scale = 1, mirror = "%s" })\n' \
        "$external" "$mode" "$internal" >"$MIRROR_FLAG"
      hyprctl reload >/dev/null 2>&1 || true
    fi
    # The intent is now realised as a live flag; drop the pending marker.
    rm -f "$MIRROR_INTENT"
  fi
}

recover_mirror() {
  # The clamshell flag disables the internal panel and survives a reboot. With
  # the omarchy-hyprland-monitor-watch killed, nothing ever re-enables it, so
  # clear it whenever it shows up (the mirror keeps DSI-1 active anyway).
  if [[ -f $CLAMSHELL_FLAG ]]; then
    log "removing stale clamshell disable flag"
    rm -f "$CLAMSHELL_FLAG"
    hyprctl reload >/dev/null 2>&1 || true
    return
  fi

  # When the external monitor goes away, remember the mirror intent but clear
  # the live flag so a lone laptop has no stale mirror rule.
  if [[ -f $MIRROR_FLAG ]] && ! omarchy hw external monitors; then
    log "no external monitor, keeping mirror intent, clearing live flag"
    mkdir -p "$HOME/.config/omarchy"
    : >"$MIRROR_INTENT"
    rm -f "$MIRROR_FLAG"
    hyprctl reload >/dev/null 2>&1 || true
    return
  fi

  restore_mirror

  # Give the user an explicit "extended mode" escape hatch: if they toggle the
  # mirror off while an external monitor is present, Omarchy drops the live
  # flag. If a pending intent survived, forget it so the mirror stays off.
  if ! [[ -f $MIRROR_FLAG ]] && [[ -f $MIRROR_INTENT ]] && omarchy hw external monitors 2>/dev/null; then
    log "mirror disabled while external present; clearing intent"
    rm -f "$MIRROR_INTENT"
  fi
}

# ---- mirror margin cleanup (Hyprland #11708) ----------------------------------
# Mirroring panels of different geometry (portrait DSI-1 -> landscape TV)
# leaves stale buffer data in the letterbox margins (black squares / trails).
# A delayed reload after the mirror is live clears it (community workaround from
# hyprwm/Hyprland#11708, verified on this GPD). A reload that fires while the
# mirror is still coming up is ineffective, hence the small delay.

schedule_mirror_cleanup() {
  if [[ ! -f $MIRROR_FLAG ]]; then
    return
  fi
  log "scheduling delayed reload to clear mirror margins"
  (
    sleep 4
    hyprctl reload >/dev/null 2>&1 || true
  ) &
}

# ---- main loop ----------------------------------------------------------------

apply_inhibit
recover_modeless
recover_mirror
apply_idle_by_external

if [[ -z $SOCKET ]] || [[ ! -S $SOCKET ]]; then
  # No Hyprland socket (e.g. headless test): periodically re-apply state.
  while true; do
    sleep 5
    apply_inhibit
    recover_modeless
    recover_mirror
    apply_idle_by_external
  done
  exit 0
fi

# The Hyprland event socket is a Unix datagram socket; socat reads it line-by-line.
while read -r event; do
  case "$event" in
    monitoradded*|monitorremoved*)
      apply_inhibit
      recover_modeless
      recover_mirror
      apply_idle_by_external
      schedule_mirror_cleanup
      ;;
    configreloaded*)
      recover_modeless
      ;;
  esac
done < <(socat -U - "UNIX-CONNECT:$SOCKET" 2>/dev/null)
