-- Monitor-Konfiguration.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
	output = "HDMI-A-1",
	mode = "preferred",
	position = "2560x0",
	scale = "1",
})

hl.monitor({
	output = "eDP-1",
	mode = "2560x1600@60",
	position = "auto",
	scale = "1.6",
})

-- Alternative Setups (bei Bedarf einkommentieren):
-- monitor=DP-1,preferred,auto,1.6,mirror,eDP-1
