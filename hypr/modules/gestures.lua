
-- ################
-- ## GESTURES ####
-- ################
hl.config({
	gestures = {
		workspace_swipe_cancel_ratio = 0.3,
		workspace_swipe_distance = 200,
		workspace_swipe_min_speed_to_force = 25,
		workspace_swipe_use_r = 1,
	},
})
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })