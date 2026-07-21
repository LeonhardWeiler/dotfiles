[[ $- != *i* ]] && return

export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
mkdir -p "$(dirname "$HISTFILE")"
shopt -s histappend

BAT_CAPACITY=
for _bat in /sys/class/power_supply/*; do
  [ -r "$_bat/type" ] && [ "$(<"$_bat/type")" = Battery ] && [ -r "$_bat/capacity" ] || continue
  BAT_CAPACITY="$_bat/capacity"; break
done
unset _bat

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

alias open='xdg-open'
alias dot='cd $HOME/dotfiles'
alias arst='sudo shutdown now'
alias todo='nvim ./AGENT/TODO.md'
alias claude='claude --dangerously-skip-permissions'

export NIX_CONFIG="experimental-features = nix-command flakes"
[ -e ~/.nix-profile/etc/profile.d/nix.sh ] && . ~/.nix-profile/etc/profile.d/nix.sh
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export npm_config_cache="${XDG_CACHE_HOME:-$HOME/.cache}/npm"
export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"
