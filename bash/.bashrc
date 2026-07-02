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

export PATH="$HOME/.config/scripts:$PATH"
export EDITOR="nvim"

export ELECTRON_OZONE_PLATFORM_HINT=wayland
export QT_QPA_PLATFORM=wayland
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=2
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export XCURSOR_SIZE=32
export BROWSER=zen-browser

export VIRSH_DEFAULT_CONNECT_URI="qemu:///system"
export TYPST_PACKAGE_PATH="$HOME/.config/typst/packages"
export GIT_CONFIG_GLOBAL="$HOME/.config/git/.gitconfig"

alias open='xdg-open'
alias dot='cd $HOME/dotfiles'
alias openimg='zen-browser'
alias arst='sudo shutdown now'
alias c='claude --dangerously-skip-permissions'
export NIX_CONFIG="experimental-features = nix-command flakes"
source ~/.nix-profile/etc/profile.d/nix.sh
export PATH="$HOME/.local/bin:$PATH"
