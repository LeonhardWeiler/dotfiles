[[ $- != *i* ]] && return

export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
mkdir -p "$(dirname "$HISTFILE")"
shopt -s histappend

# Detect the battery once at startup: the first power supply whose type is
# "Battery" (name-independent - BAT0, BAT1, CMB0, ...). Empty on a desktop.
BAT_CAPACITY=
for _bat in /sys/class/power_supply/*; do
  [ -r "$_bat/type" ] && [ "$(<"$_bat/type")" = Battery ] && [ -r "$_bat/capacity" ] || continue
  BAT_CAPACITY="$_bat/capacity"; break
done
unset _bat
# Read the battery level before every prompt from sysfs (bash builtin, no acpi subprocess).
# Without a battery (desktop) the display stays empty instead of a bare "%".
update_battery() {
  if [ -n "$BAT_CAPACITY" ] && [ -r "$BAT_CAPACITY" ]; then
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
# the dwl session wrapper config/dwl/dwl-run (QT_SCALE_FACTOR, GDK_SCALE,
# XCURSOR_SIZE, ...). That way GUI apps render the same regardless of how they
# were launched (terminal vs. rofi).

export VIRSH_DEFAULT_CONNECT_URI="qemu:///system"

alias open='xdg-open'
alias dot='cd $HOME/dotfiles'
alias arst='sudo shutdown now'
alias todo='nvim ./AGENT/TODO.md'

export NIX_CONFIG="experimental-features = nix-command flakes"
# Only source it if Nix is installed (otherwise an error in every shell without Nix).
[ -e ~/.nix-profile/etc/profile.d/nix.sh ] && . ~/.nix-profile/etc/profile.d/nix.sh
# Go: GOPATH to XDG (~/.local/share/go) instead of ~/go, to keep the home lean.
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
# npm cache to XDG (~/.cache/npm) instead of ~/.npm.
export npm_config_cache="${XDG_CACHE_HOME:-$HOME/.cache}/npm"
export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"
