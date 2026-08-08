# SPDX-License-Identifier: ISC
# Copyright (C) 2026 The leonhardweiler/dotfiles Authors
#
# OSC-133 shell integration for foot, sourced from ~/.bashrc.
#
# The markers tell foot where a prompt starts (A) and where a command's output
# begins (C) and ends (D). That drives foot's prompt jumping (Ctrl+Shift+Z/X)
# and its `pipe-command-output` key binding.
#
# The command line itself sits outside the marked output region, so it is
# stashed in a file keyed by the foot process owning this window;
# copy-last-command (Ctrl+Shift+Y) reads it back from there, since it is
# spawned by that same foot process. See README "Copying the last command and
# its output".
#
# Expects update_battery() and PROMPT_COMMAND to already exist (~/.bashrc).

case $TERM in
foot*) ;;
*) return 0 ;;
esac

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

# Runs before each command (DEBUG trap; not inherited by functions, so it only
# fires for what was typed at the prompt).
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
