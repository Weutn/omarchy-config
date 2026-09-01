-- Change the default Omarchy look'n'feel.

-- The GPD's internal panel is a small (720x1280) rotated DSI display on a
-- weak Intel UHD 600 GPU. Wider gaps/borders fragment the small surface into
-- many thin edges, which triggers more compositing passes and is a known
-- source of the occasional glitches (window edge flicker, a temporary
-- multi-coloured sliver on the screen edge, brief screen "shift", and the bar
-- momentarily re-anchoring). Tighter gaps/borders are both more usable on this
-- small portrait panel and far less demanding on the GPU.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 4,
    border_size = 1,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
