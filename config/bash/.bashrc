[[ $- != *i* ]] && return

export HISTFILE=~/.config/bash/.bash_history
mkdir -p "$(dirname "$HISTFILE")"
shopt -s histappend

BAT_CAPACITY=/sys/class/power_supply/BAT0/capacity
# Read the battery level before every prompt from sysfs (bash builtin, no acpi subprocess).
# Without a battery (desktop) the display stays empty instead of a bare "%".
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
# Scaling/cursor are deliberately NOT set here, but exclusively as session env in
# hyprland.conf (QT_SCALE_FACTOR, GDK_SCALE, XCURSOR_SIZE, ...). That way GUI apps
# render the same regardless of how they were launched (terminal vs. rofi).

export VIRSH_DEFAULT_CONNECT_URI="qemu:///system"
export TYPST_PACKAGE_PATH="$HOME/.config/typst/packages"
export GIT_CONFIG_GLOBAL="$HOME/.config/git/.gitconfig"
eval "$(dircolors ~/.dircolors)"

alias open='xdg-open'
alias dot='cd $HOME/dotfiles'
alias arst='sudo shutdown now'
alias ls='ls --color=auto'
export NIX_CONFIG="experimental-features = nix-command flakes"
# Only source it if Nix is installed (otherwise an error in every shell without Nix).
[ -e ~/.nix-profile/etc/profile.d/nix.sh ] && . ~/.nix-profile/etc/profile.d/nix.sh
# Go: GOPATH to XDG (~/.local/share/go) instead of ~/go, to keep the home lean.
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
# npm cache to XDG (~/.cache/npm) instead of ~/.npm.
export npm_config_cache="${XDG_CACHE_HOME:-$HOME/.cache}/npm"
export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"
