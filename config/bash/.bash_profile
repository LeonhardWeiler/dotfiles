[[ -f ~/.bashrc ]] && . ~/.bashrc

export GTK_THEME=Adwaita:dark
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=dwl
export XDG_THEME=dark

# Nix is already sourced conditionally in .bashrc (above via `. ~/.bashrc`);
# no second (and hardcoded) sourcing is needed here.

# Autologin: getty logs `leo` straight into tty1 (see the getty@tty1 autologin
# drop-in, deployed via `./install --getty-autologin`). Start the dwl session
# automatically from the login shell on tty1 - but only there, and not if a
# Wayland session is already running, so plain shells on other VTs are unaffected.
# `exec` replaces the shell with dwl-run so logging out of dwl logs out the VT.
if [[ -z ${WAYLAND_DISPLAY:-} && $(tty) == /dev/tty1 ]]; then
	exec dwl-run
fi
