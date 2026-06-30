-- hyprbars — title bars on windows (saneAspect style)
-- if hl.plugin and hl.plugin.hyprbars then
-- 	-- read theme surface color → darken to ~60% for subtle bar tint
-- 	local theme_bar_color = "rgba(2d353bff)"
-- 	do
-- 		local home = os.getenv("HOME")
-- 		local f = io.open(home .. "/.cache/wallpaper/current_theme", "r")
-- 		if f then
-- 			local theme = f:read("*l")
-- 			f:close()
-- 			if theme then
-- 				local pf = io.open(home .. "/.config/hypr/themes/" .. theme .. "/palette", "r")
-- 				if pf then
-- 					for line in pf:lines() do
-- 						local c = line:match("^surface=(#%x%x%x%x%x%x)$")
-- 						if c then
-- 							local r = math.floor(tonumber(c:sub(2, 3), 16) * 0.6)
-- 							local g = math.floor(tonumber(c:sub(4, 5), 16) * 0.6)
-- 							local b = math.floor(tonumber(c:sub(6, 7), 16) * 0.6)
-- 							theme_bar_color = string.format("rgba(%02x%02x%02xff)", r, g, b)
-- 							break
-- 						end
-- 					end
-- 					pf:close()
-- 				end
-- 			end
-- 		end
-- 	end
-- 	hl.config({
-- 		plugin = {
-- 			hyprbars = {
-- 				bar_height = 23,
-- 				bar_color = theme_bar_color,
-- 				bar_blur = false,
-- 				col = {
-- 					text = "rgb(d3c6aa)",
-- 				},
-- 				bar_text_size = 13,
-- 				bar_text_font = "Inter",
-- 				bar_text_align = "center",
-- 				bar_part_of_window = true,
-- 				bar_precedence_over_border = true,
-- 				bar_buttons_alignment = "left",
-- 				bar_padding = 12,
-- 				bar_button_padding = 7,
-- 				icon_on_hover = true,
-- 				bar_title_enabled = false,
-- 				on_double_click = "hyprctl dispatch fullscreen 1",
-- 			},
-- 		},
-- 	})
-- 	-- Mac traffic light buttons (L→R: close, minimize, fullscreen)
-- 	hl.plugin.hyprbars.add_button({
-- 		bg_color = "rgb(e67e80)",
-- 		fg_color = "rgb(2d353b)",
-- 		size = 10,
-- 		icon = "✕",
-- 		action = "hyprctl dispatch killactive",
-- 	})
-- 	hl.plugin.hyprbars.add_button({
-- 		bg_color = "rgb(dbbc7f)",
-- 		fg_color = "rgb(2d353b)",
-- 		size = 10,
-- 		icon = "─",
-- 		action = "hyprctl dispatch movetoworkspace special:silent",
-- 	})
-- 	hl.plugin.hyprbars.add_button({
-- 		bg_color = "rgb(a7c080)",
-- 		fg_color = "rgb(2d353b)",
-- 		size = 10,
-- 		icon = "□",
-- 		action = "hyprctl dispatch fullscreen 1",
-- 	})
-- end

-- scrolloverview — workspace overview
if hl.plugin and hl.plugin.scrolloverview then
	hl.plugin.scrolloverview.configure({
		gesture_distance = 200, -- how far is the "max" for the gesture
		scale = 0.5, -- preferred overview scale
		workspace_gap = 70,
		wallpaper = 0, -- 0: global only, 1: per-workspace only, 2: both
		blur = false, -- blur only the main overview wallpaper

		shadow = {
			enabled = false,
			range = 50,
			render_power = 3,
			color = 0xee1a1a1a,
		},
	})
end
