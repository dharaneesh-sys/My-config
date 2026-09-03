-- ##################
-- ## KEYBINDINGS ###
-- ##################
local terminal = "ghostty"
local fileManager = "nautilus"
local menu = "rofi -show drun"
local mainMod = "SUPER"

hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close())
-- QuickShell IPC Keybindings (Original binds commented out below for easy restoration)
-- Original: hl.bind(mainMod .. " + " .. "M", hl.dsp.exec_cmd("quickshell ipc call mediaPlayer toggle"))
hl.bind(mainMod .. " + " .. "M", hl.dsp.exec_cmd("quickshell ipc call shell expand media-player"))
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. "+" .. "SHIFT" .. "+" .. "D", hl.dsp.exec_cmd("opencode"))
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd(fileManager))
--hl.bind(mainMod .. " + " .. "R", hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))
hl.bind(mainMod .. " + " .. "B", hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + " .. "SHIFT" .. "+" .. "B", hl.dsp.exec_cmd("blender"))

-- Original: hl.bind(mainMod .. " + " .. "SPACE", hl.dsp.exec_cmd("quickshell ipc call launcher toggle"))
-- Original: hl.bind(mainMod .. " + " .. "SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + " .. "SPACE", hl.dsp.exec_cmd("quickshell ipc call shell expand launcher"))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "M", hl.dsp.exec_cmd("quickshell ipc call shell lock"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "N", hl.dsp.exec_cmd("vscodium"))
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "N", hl.dsp.exec_cmd("zeditor"))
hl.bind(mainMod .. " + " .. "G", hl.dsp.exec_cmd("ghostty -e nvim"))
hl.bind(mainMod .. " + " .. "V", hl.dsp.exec_cmd("quickshell ipc call shell expand clipboard"))
hl.bind(mainMod .. " + " .. "L", hl.dsp.exec_cmd("quickshell ipc call shell expand lyrics"))
hl.bind(mainMod .. " + " .. "N", hl.dsp.exec_cmd("quickshell ipc call shell expand notification-center"))
-- Original: hl.bind(mainMod .. " + " .. "N", hl.dsp.exec_cmd("swaync-client -t"))

hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "L", hl.dsp.exec_cmd("wlogout"))

-- Voice dictation: Handy (local Parakeet STT on Vulkan iGPU)
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "V", hl.dsp.exec_cmd("handy --toggle-transcription"))

--hl.bind(mainMod .. " + " .. "W", hl.dsp.exec_cmd("matuwall"))
hl.bind(mainMod .. " + " .. "W", hl.dsp.exec_cmd("quickshell ipc call shell expandWallpapers theme"))

--hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd("~/.local/bin/theme-selector"))
hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd("quickshell ipc call shell expand theme-switcher"))

--hl.bind(mainMod .. " + " .. "I", hl.dsp.exec_cmd("~/.local/bin/wallpaper-app"))
hl.bind(mainMod .. " + " .. "I", hl.dsp.exec_cmd("quickshell ipc call shell expand control-center"))
-- Full wallpaper directory (Super+Shift+I)
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "I", hl.dsp.exec_cmd("quickshell ipc call shell expandWallpapers all"))

-- Original: hl.bind(mainMod .. " + " .. "comma", hl.dsp.exec_cmd("quickshell ipc call settings toggle"))
hl.bind(mainMod .. " + " .. "comma", hl.dsp.exec_cmd("quickshell ipc call shell settingsToggle"))
hl.bind(mainMod .. " + " .. "Escape", hl.dsp.exec_cmd("quickshell ipc call shell collapse"))

-- Quickshell restart
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "R", hl.dsp.exec_cmd("pkill quickshell; sleep 0.5; quickshell &"))
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

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
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
hl.bind("SUPER + SHIFT + C", hl.dsp.window.move({ workspace = "+0" }))


-- Scroll workspaces
hl.bind(mainMod .. " + " .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + " .. "mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. "+" .. "TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT" .. "+" .. "TAB", hl.dsp.focus({ direction = "r" }))
-- Move/resize with mouse
hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots (grimblast - official hyprwm/contrib tool)
hl.bind("Print", hl.dsp.exec_cmd("XDG_SCREENSHOTS_DIR=$HOME/Pictures/Screenshots grimblast --freeze --wait 0.5 --notify copysave area"))
hl.bind(mainMod .. " + " .. "Print", hl.dsp.exec_cmd("XDG_SCREENSHOTS_DIR=$HOME/Pictures/Screenshots grimblast --notify copysave output"))
hl.bind(
    mainMod .. " + " .. "SHIFT" .. " + " .. "Print",
    hl.dsp.exec_cmd("XDG_SCREENSHOTS_DIR=$HOME/Pictures/Screenshots grimblast --notify copysave active")
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
-- Game mode: Super+F1 toggles Hyprland animations + blur off/on.
-- State lives in quickshell (GameModeState) — this just fires the IPC
-- call. Only animations + blur are touched (no gaps/borders/shadows).
hl.bind(mainMod .. " + " .. "F1", hl.dsp.exec_cmd("quickshell ipc call shell gameModeToggle"))

-- Projector / external display: Super+P cycles extend→mirror→external-only→internal-only
hl.bind(mainMod .. " + " .. "P", hl.dsp.exec_cmd("~/.config/hypr/scripts/projector.sh"))
-- Super+Shift+P: toggle mirror mode (quick shortcut for presentations)
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/projector.sh mirror"))
-- Layout: toggle scrolling/dwindle
hl.bind(mainMod .. " + SHIFT + S", function()
    local current = hl.get_config("general:layout")
    if current == "scrolling" then
        hl.config({ general = { layout = "dwindle" } })
        hl.notification.create({ text = "Layout: dwindle", timeout = 1500 })
    else
        hl.config({ general = { layout = "scrolling" } })
        hl.notification.create({ text = "Layout: scrolling", timeout = 1500 })
    end
end)

-- Scrolling layout: column management (only active when layout = scrolling)
hl.bind(mainMod .. " + " .. "bracketleft", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + " .. "bracketright", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "bracketleft", hl.dsp.layout("promote"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "bracketright", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "bracketleft", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "bracketright", hl.dsp.layout("consume_or_expel next"))
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "bracketleft", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "bracketright", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "V", hl.dsp.layout("fit visible"))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "SHIFT" .. " + " .. "F", hl.dsp.layout("fit all"))
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
-- Touchpad toggle (IdeaPad touchpad-off button, ideapad-extra-buttons -> XF86TouchpadToggle)
local touchpadName = "ftcs0038:00-2808:0106-touchpad"
hl.bind("XF86TouchpadToggle", function()
    if touchpadState == nil then touchpadState = true end
    touchpadState = not touchpadState
    hl.device({ name = touchpadName, enabled = touchpadState })
    hl.notification.create({
        text = "Touchpad " .. (touchpadState and "enabled" or "disabled"),
        timeout = 1500,
    })
end)
