-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- External HKC TV: 1080p, natural scale. Overrides the wildcard scale = 2 above.
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "auto", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- GPD internal DSI-1 is a portrait panel shown rotated (transform: 3 = 270°).
-- `scale` MUST be explicit here: Hyprland resets a transform-less/scale-less
-- monitor to scale 2 on reload, so omitting it silently drops scale changes.
-- The scaling wrapper in ~/.local/bin/omarchy-hyprland-monitor-scaling rewrites
-- this line's `scale` (keeping `transform = 3`) on every scale change, so
-- changes survive reboots.
hl.monitor({ output = "DSI-1", mode = "preferred", position = "0x0", scale = 1, transform = 3 })