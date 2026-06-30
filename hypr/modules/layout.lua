
-- ###############
-- ## DWINDLE ####
-- ###############
hl.config({
	general = {
		layout = "dwindle"
	},
	dwindle = {
		permanent_direction_override = 0,
		smart_split = 0,
		use_active_for_splits = 0,
		preserve_split = true,
	},
})
hl.workspace_rule({ workspace = "4", layout = "scrolling" })
hl.config({
	master = {
		new_status = "master",
	},
})
-- ################
-- ## ECOSYSTEM ###
-- ################
hl.config({
	ecosystem = {
		no_update_news = 1,
	},
})


