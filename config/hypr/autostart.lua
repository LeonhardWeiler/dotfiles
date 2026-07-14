-- Autostart at Hyprland start.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	hl.exec_cmd("mako") -- notification daemon
	hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
	hl.exec_cmd("~/.local/bin/change-wallpaper")
	-- Sync tracked configs (commit + push) once on login. Best effort; tolerates
	-- being offline. Replaces the former dotfiles-sync.service.
	hl.exec_cmd("~/.local/bin/dotfiles_sync")
	-- Low-battery warning: poll every 2 minutes. Replaces the former
	-- battery-check.timer/.service (plain shell loop, no systemd unit needed).
	hl.exec_cmd("sh -c 'while true; do ~/.local/bin/bat_check; sleep 120; done'")
end)
