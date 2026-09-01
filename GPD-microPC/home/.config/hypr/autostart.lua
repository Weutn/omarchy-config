-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Stop Omarchy's omarchy-hyprland-monitor-watch, whose clamshell poll disables
-- the internal panel whenever the lid is closed with an external display
-- active. That breaks an active mirror (the TV cloned a now-disabled source),
-- causing screen flicker, duplicated/oversized cursor and repeated QML scene
-- rebuilds that can crash quickshell. The mirror-safe lid handling and the
-- HDMI modeless recovery are provided by the lid-external-inhibit service
-- instead (see ~/.config/omarchy/lid-external-inhibit.sh).
hl.on("hyprland.start", function()
  hl.exec_cmd("pkill -f 'omarchy-hyprland-monitor-watch'")
end)

-- The GPD's internal panel is a portrait DSI shown rotated (transform = 3).
-- Omarchy reorders PATH so /usr/share/omarchy/bin comes first, which means the
-- Display panel (quickshell) resolves omarchy-hyprland-monitor-scaling to the
-- packaged script that drops the rotation on every scale change. We shadow it
-- with a fixed wrapper in ~/.local/bin that preserves transform=3 and applies
-- the exact requested scale (see that file). Prepend ~/.local/bin so quickshell
-- (and shell panels started after Hyprland reaches this point) pick up ours.
local user_bin = os.getenv("HOME") .. "/.local/bin"
hl.env("PATH", user_bin .. ":" .. (os.getenv("PATH") or ""))
