-- Programs referenced in keybinds and autostart. Bundled centrally so a change
-- (e.g. a different terminal) is only needed in one place. Included by other
-- modules via `require("programs")`.
return {
	terminal = "alacritty",
	menu = "rofi -show drun",
	browser = "zen-browser",
	lock = "hyprlock",
	pass = "~/.local/bin/rofi_keepassxc -d ~/.config/keepassxc/Passwords.kdbx",
	files = "rofi -show filebrowser",
	wsmgr = "~/.local/bin/rofi_workspace_manager",
}
