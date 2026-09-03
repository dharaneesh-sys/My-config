-- #############################
-- ## WINDOWS AND WORKSPACES ###
-- #############################
-- (swaync layer rules removed — notifications now render in the
--  quickshell notification-center panel; see QUICKSHELL section below)
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})
-- window_rule float and center need actual booleans
hl.window_rule({ match = { class = "wallpaper-switch" }, float = true })
hl.window_rule({ match = { class = "wallpaper-switch" }, size = "900 600" })
hl.window_rule({ match = { class = "wallpaper-switch" }, center = true })

-- wallpaper-app: new GTK wallpaper selector
hl.window_rule({ match = { title = "Wallpaper Selector" }, float = true })
hl.window_rule({ match = { title = "Wallpaper Selector" }, size = "860 340" })
hl.window_rule({ match = { title = "Wallpaper Selector" }, center = true })
hl.window_rule({ match = { title = "Wallpaper Selector" }, border_size = 0 })
hl.window_rule({ match = { title = "Wallpaper Selector" }, no_shadow = true })
hl.window_rule({ match = { title = "Wallpaper Selector" }, animation = "gnomed" })
-- preview popup — inherits float from dialog hint, no size override needed
hl.window_rule({ match = { title = "^Preview" }, float = true })
hl.window_rule({ match = { title = "^Preview" }, center = true })
hl.window_rule({ match = { title = "^Preview" }, border_size = 0 })
hl.window_rule({ match = { title = "^Preview" }, animation = "slide" })

-- theme-selector: GTK4 visual theme picker
hl.window_rule({ match = { title = "Theme Selector" }, float = true })
hl.window_rule({ match = { title = "Theme Selector" }, size = "400 500" })
hl.window_rule({ match = { title = "Theme Selector" }, center = true })
hl.window_rule({ match = { title = "Theme Selector" }, border_size = 0 })
hl.window_rule({ match = { title = "Theme Selector" }, no_shadow = true })
hl.window_rule({ match = { title = "Theme Selector" }, animation = "gnomed" })

-- Matuwall wallpaper picker
hl.window_rule({ match = { class = "com\\.kwimy\\.Matuwall" }, float = true })
hl.window_rule({ match = { class = "com\\.kwimy\\.Matuwall" }, size = "900 600" })
hl.window_rule({ match = { class = "com\\.kwimy\\.Matuwall" }, center = true })
hl.window_rule({ match = { class = "com\\.kwimy\\.Matuwall" }, border_size = 0 })
hl.window_rule({ match = { class = "com\\.kwimy\\.Matuwall" }, no_shadow = true })

-- Nautilus file manager
hl.window_rule({ match = { class = "org\\.gnome\\.Nautilus" }, float = true })
hl.window_rule({ match = { class = "org\\.gnome\\.Nautilus" }, size = "900 600" })
hl.window_rule({ match = { class = "org\\.gnome\\.Nautilus" }, no_shadow = true })
-- hyprpolkitagent authentication dialog
hl.window_rule({ match = { class = "hyprpolkitagent" }, float = true })
hl.window_rule({ match = { class = "hyprpolkitagent" }, center = true })
hl.window_rule({ match = { class = "hyprpolkitagent" }, size = "300 200" })
hl.window_rule({ match = { class = "hyprpolkitagent" }, border_size = 0 })
hl.window_rule({ match = { class = "hyprpolkitagent" }, no_shadow = true })
hl.window_rule({ match = { class = "hyprpolkitagent" }, no_blur = false })

-- Floating dialogs & popups
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true, center = true, size = "800 600" })
hl.window_rule({ match = { class = "xdg-desktop-portal-hyprland" }, float = true, center = true, size = "800 600" })
hl.window_rule({ match = { class = "pavucontrol" }, float = true, center = true, size = "900 600" })
hl.window_rule({ match = { class = "blueman-manager" }, float = true, center = true, size = "800 600" })
hl.window_rule({ match = { class = "nm-connection-editor" }, float = true, center = true })
hl.window_rule({ match = { class = "pinentry" }, float = true, center = true })
hl.window_rule({ match = { class = "org.gnome.Calculator" }, float = true, center = true, size = "400 500" })
hl.window_rule({ match = { class = "obsidian" }, workspace = "special:notes" })

hl.layer_rule({ match = { namespace = "rofi" }, animation = "popin", dim_around = true })
hl.window_rule({ match = { class = "^(rofi)$" }, float = true })
hl.window_rule({ match = { class = "^(rofi)$" }, center = true })
hl.window_rule({ match = { class = "^(rofi)$" }, size = "520 0" })
hl.window_rule({ match = { class = "^(rofi)$" }, border_size = 0 })
hl.window_rule({ match = { class = "^(rofi)$" }, no_shadow = true })

-- hyprglass: glass effect on terminal windows only (global enabled=false)
hl.window_rule({ match = { class = ".*[Gg]hostty.*" },          tag = "+hyprglass_enabled" })
hl.window_rule({ match = { class = "foot" },                     tag = "+hyprglass_enabled" })
-- nautilus file manager
hl.window_rule({ match = { class = "org%.gnome%.Nautilus" }, tag = "+hyprglass_enabled" })
-- both terminals use default_preset = "subtle"

-- ##############################
-- ## QUICKSHELL FLOATING UI ####
-- ##############################
-- Rounded cards on layer-shell surfaces: only blur the opaque card pixels
-- (ignore_alpha 0.1) and xray (frost what's BEHIND the surface, not the
-- surface content), so the global decoration.blur no longer paints a
-- rectangular ghost box past the rounded panels / across the island strip.
-- Quickshell: no layer animation — panels animate their own height/opacity
-- in QML, so Hyprland must not fire layersIn/layersOut (slide right) on map.
-- All quickshell windows share the default "quickshell" namespace.
hl.layer_rule({ match = { namespace = "quickshell" }, no_anim = true })

-- slurp area-selection overlay: kill layer animations so grimblast does not
-- capture the selection border. grimblast injects this rule itself via
-- `hyprctl keyword layerrule`, but that keyword is a no-op on the non-legacy
-- parser of Hyprland >= 0.56, so it must live in the config permanently.
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })

-- (removed stale per-panel rules: dynamic-island/launcher/settings/theme-picker
--  — no surface uses those namespaces anymore; see quickshell rule above)
