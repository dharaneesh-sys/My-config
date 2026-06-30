-- ##################
-- ## KEYBINDINGS ###
-- ##################
local terminal = "ghostty"
local fileManager = "nautilus"
local menu = "rofi -show drun"
local mainMod = "SUPER"

hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close())
hl.bind(
	mainMod .. " + " .. "M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")
)
hl.bind(mainMod.. "+" .. "SHIFT" .. "+" .. "D", hl.dsp.exec_cmd("opencode"))
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + " .. "R", hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))
hl.bind(mainMod .. " + " .. "B", hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + " .. "SHIFT" .. "+" .. "B", hl.dsp.exec_cmd("blender"))
hl.bind(mainMod .. " + " .. "SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "M", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "N", hl.dsp.exec_cmd("vscodium"))
hl.bind(mainMod .. " + " .. "G", hl.dsp.exec_cmd("ghostty -e nvim"))
hl.bind(mainMod .. " + " .. "V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + " .. "N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "L", hl.dsp.exec_cmd("wlogout"))
-- Super+W / Super+Shift+A / Super+I: visual wallpaper pickers (thumbnail grid)
hl.bind(mainMod .. " + " .. "W", hl.dsp.exec_cmd("matuwall"))
hl.bind(mainMod .. " + " .. "I", hl.dsp.exec_cmd("~/.local/bin/wallpaper-app")) -- Super+I: new GTK wallpaper selector (Images)
hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd("~/.local/bin/theme-selector"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "T", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    local mons = hl.get_monitors()
    if mons and #mons > 0 then
        local m = mons[1]
        hl.dispatch(hl.dsp.window.resize({
            x = math.floor(m.width * 0.45),
            y = math.floor(m.height * 0.40)
        }))
    end
    hl.dispatch(hl.dsp.window.center())
end)
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "P", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind(
	mainMod .. " + " .. "SHIFT" .. " + " .. "W",
	hl.dsp.exec_cmd("gtk-launch brave-hnpfjngllnobngcgfapefoaidbinmjnm-Default.desktop")
)
hl.bind(mainMod .. "+" .. "grave", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:201", hl.dsp.exec_cmd(terminal))
--hl.bind(mainMod .. " + " .. "RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + " .. "F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + " .. "S", hl.dsp.exec_cmd("gtk-launch brave-cinhimbnkkaeohfgghhklpknlkffjgod-Default.desktop"))
--hl.bind("SUPER + RETURN", function()
--hl.dispatch(hl.dsp.exec_cmd("ghostty --gtk-single-instance=true"))
--end)
hl.bind("SUPER + RETURN", function()
	hl.dispatch(hl.dsp.exec_cmd("foot"))
end)
--hl.bind("SUPER + Z", function()
----	hl.dispatch(hl.dsp.exec_cmd("skwd wall toggle"))
--end)
hl.bind("SUPER + A", function()
	hl.dispatch(hl.dsp.exec_cmd("~/.local/bin/toggle-notes"))
end)
hl.bind("ALT + space", function()
	hl.dispatch(hl.dsp.exec_cmd("notify-send 'Windows sucks'"))
end)
-- hyprland.lua
hl.bind("SUPER + D", function()
	if hl.plugin and hl.plugin.scrolloverview then
		hl.plugin.scrolloverview.overview("toggle")
	end
end)

-- Move focus
hl.bind(mainMod .. " + " .. "left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + " .. "right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + " .. "up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + " .. "down", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + " .. "h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + " .. "l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + " .. "k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + " .. "j", hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Switch workspaces
hl.bind(mainMod .. " + " .. "1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + " .. "2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + " .. "3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + " .. "4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + " .. "5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + " .. "6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + " .. "7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + " .. "8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + " .. "9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + " .. "0", hl.dsp.focus({ workspace = 10 }))

-- Move window to workspace
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "0", hl.dsp.window.move({ workspace = 10 }))
hl.bind("SUPER + C", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind("SUPER + SHIFT + C", hl.dsp.window.move({ workspace = " " }))


-- Scroll workspaces
hl.bind(mainMod .. " + " .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + " .. "mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. "+" .. "TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT" .. "+" .. "TAB", hl.dsp.focus({ direction = "r" }))
-- Move/resize with mouse
hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --output-folder ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + " .. "Print", hl.dsp.exec_cmd("hyprshot -m output --output-folder ~/Pictures/Screenshots"))
hl.bind(
	mainMod .. " + " .. "SHIFT" .. " + " .. "Print",
	hl.dsp.exec_cmd("hyprshot -m window --output-folder ~/Pictures/Screenshots")
)

local MAX_ZOOM = 3
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

---@param offset number
---@return nil
local function zoom(offset)
	local current = hl.get_config("cursor.zoom_factor")
	if offset ~= nil then
		current = current + offset
	elseif current ~= MIN_ZOOM then
		current = MIN_ZOOM
	else
		current = ZOOM_TOGGLE_FACTOR
	end
	current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
	hl.config({ cursor = { zoom_factor = current } })
end

hl.bind("SUPER + Z", zoom)
hl.bind("SUPER + plus", function()
	zoom(0.5)
end)
hl.bind("SUPER + minus", function()
	zoom(-0.5)
end)

hl.bind("SUPER + X", function()
	hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
	hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
	hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
	hl.dispatch(hl.dsp.window.move({ workspace = "special:minimize" }))
	hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
end)
hl.bind("SUPER + F1", function()
	local game_mode = (hl.get_config("animations.enabled") == false)

	if game_mode then
		hl.exec_cmd("hyprctl reload")
		return
	end

	hl.config({
		general = {
			gaps_in = 0,
			gaps_out = 0,              -- Disable gaps
			border_size = 0,
		},

		animations = {
			enabled = false, -- Disable animations
		},

		-- Disable blur, shadow and window rounding
		decoration = {
			shadow = { enabled = false },
			blur = { enabled = false },
			rounding = 0,
		}
	})
end)
-- -- Layout
-- hl.bind(mainMod .. " + " .. "period", hl.dsp.layout("move+col"))
-- hl.bind(mainMod .. " + " .. "comma", hl.dsp.layout("move-col"))
-- hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "period", hl.dsp.layout("movewindowtor"))
-- hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "comma", hl.dsp.layout("movewindowtol"))
-- hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "up", hl.dsp.layout("movewindowtou"))
-- hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "down", hl.dsp.layout("movewindowtod"))

-- -- Scrolling layout: column management
-- hl.bind(mainMod .. " + " .. "bracketleft", hl.dsp.layout("focus l"))
-- hl.bind(mainMod .. " + " .. "bracketright", hl.dsp.layout("focus r"))
-- hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "bracketleft", hl.dsp.layout("promote"))
-- hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "bracketright", hl.dsp.layout("swapcol r"))
-- hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "bracketleft", hl.dsp.layout("swapcol l"))
-- hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "bracketright", hl.dsp.layout("consume_or_expel next"))
-- hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "bracketleft", hl.dsp.layout("colresize -conf"))
-- hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "bracketright", hl.dsp.layout("colresize +conf"))
-- hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "V", hl.dsp.layout("fit_into_view"))
-- hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "SHIFT" .. " + " .. "F", hl.dsp.layout("fit all"))
--hl.gesture({
--	fingers = 3,
--	direction = "left",
--	action = function()
--		hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
--	end,
--})
--hl.gesture({
--	fingers = 3,
--direction = "right",
--	action = function()
--		hl.dispatch(hl.dsp.window.cycle_next())
--	end,
--})
hl.gesture({ fingers = 3, direction = "down", mods = "ALT", action = "close" })
-- Brightness / Volume / Media
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/.config/scripts/brightness.sh --inc"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/scripts/brightness.sh --dec"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/scripts/volume.sh --inc"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/scripts/volume.sh --dec"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("~/.config/scripts/volume.sh --mute"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
