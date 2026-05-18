[[ -f ~/.bashrc ]] && . ~/.bashrc

export GTK_THEME=Adwaita:dark
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_THEME=dark

if [ -e /home/leo/.nix-profile/etc/profile.d/nix.sh ]; then . /home/leo/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
