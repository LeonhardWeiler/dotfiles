[[ -f ~/.bashrc ]] && . ~/.bashrc

export GTK_THEME=Adwaita:dark
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=dwl
export XDG_THEME=dark

if [[ -z ${WAYLAND_DISPLAY:-} && $(tty) == /dev/tty1 ]]; then
	exec dwl
fi
