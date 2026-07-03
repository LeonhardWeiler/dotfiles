[[ $- != *i* ]] && return

export HISTFILE=~/.config/bash/.bash_history
mkdir -p "$(dirname "$HISTFILE")"
shopt -s histappend

BAT_CAPACITY=/sys/class/power_supply/BAT0/capacity
# Akkustand vor jedem Prompt aus sysfs lesen (Bash-Builtin, kein acpi-Subprozess).
# Ohne Akku (Desktop) bleibt die Anzeige leer statt eines nackten "%".
update_battery() {
  if [ -r "$BAT_CAPACITY" ]; then
    battery="$(<"$BAT_CAPACITY")% "
  else
    battery=""
  fi
}
PROMPT_COMMAND=update_battery

PS1='${battery}\w \$ '

export EDITOR="nvim"

export ELECTRON_OZONE_PLATFORM_HINT=wayland
export QT_QPA_PLATFORM=wayland
export BROWSER=zen-browser
# Skalierung/Cursor werden bewusst NICHT hier gesetzt, sondern ausschliesslich
# als Session-Env in hyprland.conf (QT_SCALE_FACTOR, GDK_SCALE, XCURSOR_SIZE,
# ...). So rendern GUI-Apps unabhaengig vom Startweg (Terminal vs. Rofi) gleich.

export VIRSH_DEFAULT_CONNECT_URI="qemu:///system"
export TYPST_PACKAGE_PATH="$HOME/.config/typst/packages"
export GIT_CONFIG_GLOBAL="$HOME/.config/git/.gitconfig"

alias open='xdg-open'
alias dot='cd $HOME/dotfiles'
alias openimg='zen-browser'
alias arst='sudo shutdown now'
export NIX_CONFIG="experimental-features = nix-command flakes"
# Nur einbinden, wenn Nix installiert ist (sonst Fehler in jeder Shell ohne Nix).
[ -e ~/.nix-profile/etc/profile.d/nix.sh ] && . ~/.nix-profile/etc/profile.d/nix.sh
export PATH="$HOME/.local/bin:$PATH"
