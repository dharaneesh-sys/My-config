-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",
	transparency = true,
}

M.nvdash = {
	load_on_startup = true,
	header = {
		"                      ",
		"  ▄▄         ▄ ▄▄▄▄▄▄▄",
		"▄▀███▄     ▄██ █████▀ ",
		"██▄▀███▄   ███        ",
		"███  ▀███▄ ███        ",
		"███    ▀██ ███        ",
		"███      ▀ ███        ",
		"▀██ █████▄▀█▀▄██████▄ ",
		"  ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀",
		"                      ",
		"  Powered By  eovim ",
		"                      ",
	},
	buttons = {
		{ txt = "  Find File", keys = "ff", cmd = "Telescope find_files" },
		{ txt = "  Recent Files", keys = "fo", cmd = "Telescope oldfiles" },
		{ txt = "󰈭  Find Word", keys = "fw", cmd = "Telescope live_grep" },
		{ txt = "󰭎  Mason", keys = "cm", cmd = "Mason" },
		{ txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet" },
	},
}

return M
