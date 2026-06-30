

-- ################
-- ## ANIMATIONS ##
-- ################
--
-- NOTE: speed = duration in 100ms increments. LOWER = FASTER.
--   speed 3 = 300ms, speed 5 = 500ms, speed 10 = 1000ms.
--
-- Available styles: slide, popin, zoom, fade, slidevert, slidefade
-- Curves used: snap, smooth, overshot, linear

hl.config({
	animations = {
		enabled = true,
	},
})

-- Snappy ease-out (fast ramp, smooth settle) — primary curve
hl.curve("snap", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1.0 } } })

-- Smooth settle — for fades
hl.curve("smooth", { type = "bezier", points = { { 0.12, 0.92 }, { 0.08, 1.0 } } })

-- Overshoot bounce — for workspace switches
hl.curve("overshot", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1.0 } } })

-- Linear — for border-angle spin loop
hl.curve("linear", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })


-- Windows — fast slide (300ms), close is snappier (200ms)
hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "snap", style = "slide" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3, bezier = "snap", style = "slide popin 95%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "snap", style = "slide" })
hl.animation({ leaf = "windowsMove",enabled = true, speed = 3, bezier = "snap", style = "slide" })

-- Layers (popups, menus, notifications) — quick (300-400ms)
hl.animation({ leaf = "layers",    enabled = true, speed = 4, bezier = "snap" })
hl.animation({ leaf = "layersIn",  enabled = true, speed = 4, bezier = "snap", style = "slide right" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "snap", style = "slide right" })

-- Fades — subtle and brisk (400-500ms)
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 4, bezier = "smooth" })

-- Workspaces — slide with bounce (500ms)
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "overshot", style = "slide" })
hl.animation({
  leaf = "specialWorkspace",
  enabled = true,
  speed = 5,
  bezier = "overshot",
  style = "slidefadevert 100%",
})

-- Border color transitions — instant feel (200ms)
hl.animation({ leaf = "border",    enabled = true, speed = 2, bezier = "snap" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 20, bezier = "linear", style = "loop" })
