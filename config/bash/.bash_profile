[[ -f ~/.bashrc ]] && . ~/.bashrc

export GTK_THEME=Adwaita:dark
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_THEME=dark

# Nix is already sourced conditionally in .bashrc (above via `. ~/.bashrc`);
# no second (and hardcoded) sourcing is needed here.
