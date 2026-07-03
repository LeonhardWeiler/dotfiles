-- Look & Feel, Layout und Eingabe (ein gebuendelter hl.config-Aufruf).
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 10,
		border_size = 2,
		-- https://wiki.hypr.land/Configuring/Variables/#variable-types fuer Farben
		col = {
			active_border = "rgb(dddddd)",
			inactive_border = "rgb(595959)",
		},
		-- Fenster durch Ziehen an Rand/Gaps groessen
		resize_on_border = true,
		-- Siehe https://wiki.hypr.land/Configuring/Tearing/ vor dem Aktivieren
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
	-- Animationen global deaktiviert (Kurven/Leaves in animations.lua bleiben aber
	-- definiert und werden bei enabled = true sofort wirksam).
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
		sensitivity = 0, -- -1.0 - 1.0, 0 = keine Aenderung
		touchpad = {
			natural_scroll = false,
		},
	},
})
