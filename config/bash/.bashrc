[[ $- != *i* ]] && return

export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
mkdir -p "$(dirname "$HISTFILE")"
shopt -s histappend

BAT_CAPACITY=
for _bat in /sys/class/power_supply/*; do
  [ -r "$_bat/type" ] && [ "$(<"$_bat/type")" = Battery ] && [ -r "$_bat/capacity" ] || continue
  BAT_CAPACITY="$_bat/capacity"
  break
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


# OSC-133 shell integration for foot: mark where a prompt starts (A) and
# where a command's output begins (C) and ends (D).  This is what lets foot
# jump between prompts and pipe the last command's output somewhere - see the
# copy-last-command key binding in config/foot/foot.ini.  The command line
# itself sits outside the marked output region, so stash it in a file keyed by
# the foot process owning this window; copy-last-command reads it back from
# there (it is spawned by that same foot process).
case $TERM in
foot*)
  # Walk up the parent chain to the owning foot process, once per shell.
  _foot_pid() {
    local pid=$PPID comm key value next
    while [ "$pid" -gt 1 ] 2>/dev/null; do
      read -r comm < "/proc/$pid/comm" 2>/dev/null || return 1
      [ "$comm" = foot ] && { printf '%s' "$pid"; return 0; }
      next=
      while read -r key value; do
        [ "$key" = PPid: ] && { next=$value; break; }
      done < "/proc/$pid/status" 2>/dev/null
      [ -n "$next" ] || return 1
      pid=$next
    done
    return 1
  }

  _LAST_COMMAND_FILE=
  if _pid=$(_foot_pid); then
    _LAST_COMMAND_FILE="${XDG_RUNTIME_DIR:-/tmp}/foot-last-command.$_pid"
  fi
  unset _pid

  # Runs before each command (DEBUG trap; not inherited by functions, so it
  # only fires for what was typed at the prompt).
  _osc133_preexec() {
    [ -n "$COMP_LINE" ] && return                    # tab completion, not a command
    [ -n "$_osc133_running" ] && return              # only the first command of a line
    case $BASH_COMMAND in _osc133_precmd*) return ;; esac
    _osc133_running=1
    printf '\033]133;C\033\\'
    if [ -n "$_LAST_COMMAND_FILE" ]; then
      local entry
      entry=$(HISTTIMEFORMAT= builtin history 1)
      printf '%s\n' "${entry#*[0-9]  }" > "$_LAST_COMMAND_FILE"
    fi
  }

  _osc133_precmd() {
    local status=$?
    printf '\033]133;D;%s\033\\\033]133;A\033\\' "$status"
    _osc133_running=
    update_battery
  }

  PROMPT_COMMAND=_osc133_precmd
  trap '_osc133_preexec' DEBUG
  ;;
esac


export EDITOR="nvim"
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export QT_QPA_PLATFORM=wayland
export BROWSER=zen-browser


alias open='xdg-open'
alias dot='cd $HOME/dotfiles'
alias notes='cd $HOME/files/repos/notes/'
alias arst='sudo shutdown now'
alias todo='nvim ./AGENT/TODO.md'
alias claude='claude --dangerously-skip-permissions'
alias camera='ffplay -f v4l2 /dev/video0 -vf hflip -x 1280 -y 720'
alias screenshot='grim -g "$(slurp)"'


export NIX_CONFIG="experimental-features = nix-command flakes"

[ -e ~/.nix-profile/etc/profile.d/nix.sh ] && . ~/.nix-profile/etc/profile.d/nix.sh

export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export npm_config_cache="${XDG_CACHE_HOME:-$HOME/.cache}/npm"

export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"

[ -f "/home/leo/.ghcup/env" ] && . "/home/leo/.ghcup/env"
