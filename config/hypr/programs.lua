-- Programs referenced in keybinds and autostart. Bundled centrally so a change
-- (e.g. a different terminal) is only needed in one place. Included by other
-- modules via `require("programs")`.
return {
	terminal = "alacritty",
	menu = "rofi -show drun",
	browser = "zen-browser",
	lock = "hyprlock",
	files = "rofi -show filebrowser",
}
