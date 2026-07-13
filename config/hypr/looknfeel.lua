-- Look & feel, layout and input (one bundled hl.config call).
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 6,
		border_size = 0,
		-- https://wiki.hypr.land/Configuring/Variables/#variable-types for colors
		col = {
			active_border = "rgb(dddddd)",
			inactive_border = "rgb(595959)",
		},
		-- Resize windows by dragging on the border/gaps
		resize_on_border = true,
		-- See https://wiki.hypr.land/Configuring/Tearing/ before enabling
		allow_tearing = false,
		layout = "master",
	},
	xwayland = {
		force_zero_scaling = true,
	},
	-- https://wiki.hypr.land/Configuring/Variables/#decoration
	decoration = {
		rounding = 0,
		rounding_power = 0,
	},
	-- Animations disabled globally (curves/leaves in animations.lua stay defined
	-- though and take effect immediately when enabled = true).
	animations = {
		enabled = false,
	},
	-- See https://wiki.hypr.land/Configuring/Master-Layout/
	master = {
		new_status = "slave",
	},
	-- https://wiki.hypr.land/Configuring/Variables/#misc
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
	-- https://wiki.hypr.land/Configuring/Variables/#input
	input = {
		kb_layout = "us",
		kb_variant = "colemak_dh",
		kb_options = "caps:swapescape",
		repeat_delay = 300,
		follow_mouse = 1,
		sensitivity = 0, -- -1.0 - 1.0, 0 = no change
		touchpad = {
			natural_scroll = false,
		},
	},
})
