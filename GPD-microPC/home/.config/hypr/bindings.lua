-- GPD MicroPC personal keybindings (2026-08-26)
-- Two-key combos only, tuned for a tiny handheld.
-- Backup: bindings.lua.bak.* in this directory.

---------------------------------------------------------------------------
-- UNBIND defaults that conflict with the new bindings
---------------------------------------------------------------------------

-- SUPER+SPACE was: Omarchy menu (rebind with French description)
hl.unbind("SUPER + SPACE")
-- SUPER+BACKSPACE was: toggle window transparency
hl.unbind("SUPER + BACKSPACE")
-- SUPER+N was: editor
hl.unbind("SUPER + N")
-- SUPER+O was: pop window out (float & pin)
hl.unbind("SUPER + O")
-- SUPER+P was: pseudo window
hl.unbind("SUPER + P")
-- SUPER+L was: toggle workspace layout
hl.unbind("SUPER + L")
-- SUPER+J was: toggle window split
hl.unbind("SUPER + J")
-- SUPER+SLASH was: monitor scaling up
hl.unbind("SUPER + SLASH")
-- SUPER+RETURN was: terminal (rebind with French description)
hl.unbind("SUPER + RETURN")
-- SUPER+APOSTROPHE: no default binding, safe to bind directly
-- SUPER+COMMA was: dismiss last notification
hl.unbind("SUPER + comma")
-- SUPER+PERIOD: no default binding, safe to bind directly
-- SUPER+BACKSLASH: no default binding, safe to bind directly
-- SUPER+LEFT/RIGHT/UP/DOWN: unbind defaults that conflict with focus bindings
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
-- Lid close: default Omarchy clamshell disables the internal panel, which
-- breaks an active mirror. Replace it with a mirror-safe handler (rebound below).
hl.unbind("switch:off:Lid Switch")
hl.unbind("switch:on:Lid Switch")

---------------------------------------------------------------------------
-- MENU
---------------------------------------------------------------------------

o.bind("SUPER + SPACE", "Ouvrir le menu Omarchy", "omarchy-menu toggle")
o.bind("SUPER + G", "Grand écran (maximiser)", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + R", "Ouvrir RetroArch", { launch = "retroarch" })
o.bind("SUPER + Y", "Gestionnaire de fichiers (Yazi)", "omarchy-launch-or-focus-tui yazi")

---------------------------------------------------------------------------
-- WINDOW MANAGEMENT
---------------------------------------------------------------------------

o.bind("SUPER + BACKSPACE", "Fermer la fenêtre", hl.dsp.window.close())
o.bind("SUPER + RETURN", "Ouvrir le terminal", { omarchy = "terminal" })
o.bind("SUPER + N", "Ouvrir Chromium", { launch = "chromium" })
o.bind("SUPER + O", "Basculer fenêtre flottante", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + P", "Basculer pseudo-tile", hl.dsp.window.pseudo())
o.bind("SUPER + L", "Changer le layout", "omarchy-hyprland-workspace-layout-toggle")
o.bind("SUPER + J", "Basculer orientation du split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + M", "Médias de la forge", "omarchy-launch-or-focus-tui forge-media")
o.bind("SUPER + I", "Plein écran interne", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + SLASH", "Plein écran", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + APOSTROPHE", "Épingler la fenêtre", function()
  hl.dispatch("pin")
end)

---------------------------------------------------------------------------
-- FOCUS NAVIGATION
---------------------------------------------------------------------------

o.bind("SUPER + LEFT", "Focus à gauche", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + RIGHT", "Focus à droite", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + UP", "Focus en haut", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + DOWN", "Focus en bas", hl.dsp.focus({ direction = "d" }))

---------------------------------------------------------------------------
-- WORKSPACES
---------------------------------------------------------------------------

o.bind("SUPER + comma", "Workspace précédent", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + period", "Workspace suivant", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + BACKSLASH", "Basculer entre fenêtres", hl.dsp.window.cycle_next())

o.bind("ALT + 1", "Aller au workspace 1", hl.dsp.focus({ workspace = "1" }))
o.bind("ALT + 2", "Aller au workspace 2", hl.dsp.focus({ workspace = "2" }))
o.bind("ALT + 3", "Aller au workspace 3", hl.dsp.focus({ workspace = "3" }))
o.bind("ALT + 4", "Aller au workspace 4", hl.dsp.focus({ workspace = "4" }))

---------------------------------------------------------------------------
-- SCREENSHOT
---------------------------------------------------------------------------

o.bind("ALT + P", "Capture d'écran", "omarchy-capture-screenshot")

----------------------------------------------------------------------------------
-- LID CLOSE (mirror desktop mode)
-- Closing the lid while mirroring does nothing: the mirror and internal panel
-- stay on so desktop use on the TV continues (suspension is already inhibited
-- while an external monitor is present). Without a mirror, Omarchy's normal
-- clamshell behaviour applies (e.g. suspend when alone).
----------------------------------------------------------------------------------

o.bind("switch:off:Lid Switch", "Capot fermé (miroir: ne rien faire)",
  "/home/weutn/.config/omarchy/lid-close-safe.sh", { locked = true })
