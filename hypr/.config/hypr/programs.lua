-- Programme, die in Keybinds und Autostart referenziert werden. Zentral
-- gebuendelt, damit ein Wechsel (z. B. anderes Terminal) nur an einer Stelle
-- noetig ist. Wird von anderen Modulen per `require("programs")` eingebunden.
return {
	terminal = "alacritty",
	menu = "rofi -show drun",
	browser = "zen-browser",
	lock = "hyprlock",
	pass = "~/.local/bin/rofi_keepassxc -d ~/.config/keepassxc/Passwords.kdbx",
	files = "rofi -show filebrowser",
	wsmgr = "~/.local/bin/rofi_workspace_manager",
}
