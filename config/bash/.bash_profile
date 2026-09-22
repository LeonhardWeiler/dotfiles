[[ -f ~/.bashrc ]] && . ~/.bashrc

# On this machine the graphical session is started by plasmalogin.service, not
# from this file - Plasma sets XDG_CURRENT_DESKTOP, the Qt platform theme and
# the GTK theme itself (kde-gtk-config). Environment variables for GUI apps
# belong in config/kde/environment.conf, which the session actually reads.
#
# The dwl machine started its compositor here instead:
#   export GTK_THEME=Adwaita:dark
#   export QT_QPA_PLATFORMTHEME=qt5ct
#   export XDG_CURRENT_DESKTOP=dwl
#   if [[ -z ${WAYLAND_DISPLAY:-} && $(tty) == /dev/tty1 ]]; then exec dwl; fi
