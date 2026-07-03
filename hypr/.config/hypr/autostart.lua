-- Autostart beim Hyprland-Start.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	hl.exec_cmd("mako") -- Notification-Daemon
	hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
	hl.exec_cmd("~/files/projects/wallpaper/change-wallpaper.sh")
end)
