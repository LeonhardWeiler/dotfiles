#!/usr/bin/env bash
# lib_hypr.sh — shared helpers for the Hyprland workspace automation.
# Sourced (via `source`) and requires bash (arrays, local, process
# substitution). Every window is addressed via its stable address, new windows
# are detected via an address diff (instead of fragile titles).

# --- Configuration (overridable via the environment) -------------------------
: "${HYPR_WAIT_TIMEOUT:=15}"    # seconds before waiting for a window gives up
: "${HYPR_WAIT_INTERVAL:=0.1}"  # poll interval in seconds

log() { printf '[slf] %s\n' "$*" >&2; }

# Abort with an error message (also as a rofi popup if available).
die() {
  printf '[slf] ERROR: %s\n' "$*" >&2
  command -v rofi >/dev/null 2>&1 && rofi -e "SLF workspace: $*" >/dev/null 2>&1
  exit 1
}

# Check that all required commands are present.
require_cmds() {
  local missing=0 c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || { log "missing command: $c"; missing=1; }
  done
  [ "$missing" -eq 0 ] || die "required programs missing (see log above)."
}

# Print all window addresses of a class (one per line).
addresses_of_class() {
  hyprctl clients -j | jq -r --arg c "$1" '.[] | select(.class==$c) | .address'
}

# Wait until a NEW address of class $1 appears (diff against the newline-
# separated list of known addresses passed in $2) and print it. Returns 1 on
# timeout.
wait_for_new_window() {
  local class="$1" before="$2" addr
  local deadline=$(( $(date +%s) + HYPR_WAIT_TIMEOUT ))
  while [ "$(date +%s)" -le "$deadline" ]; do
    while IFS= read -r addr; do
      [ -n "$addr" ] || continue
      case "$before" in
        *"$addr"*) : ;;                       # was already there
        *) printf '%s\n' "$addr"; return 0 ;; # new -> return it
      esac
    done < <(addresses_of_class "$class")
    sleep "$HYPR_WAIT_INTERVAL"
  done
  return 1
}

# First zen window address on a given workspace (empty if none).
zen_on_ws() {
  hyprctl clients -j \
    | jq -r --argjson w "$1" '.[] | select(.class=="zen" and .workspace.id==$w) | .address' \
    | head -n1
}

# Move a window (address) silently (without focus change) to a workspace.
move_window_to_ws() {
  hyprctl dispatch movetoworkspacesilent "$2,address:$1" >/dev/null
}

focus_ws()     { hyprctl dispatch workspace "$1" >/dev/null; }
focus_window() { hyprctl dispatch focuswindow "address:$1" >/dev/null; }

# Set the currently focused workspace to master orientation left and a 50/50
# split. Errors are swallowed (the default mfact is close enough).
master_split_5050() {
  hyprctl dispatch layoutmsg orientationleft >/dev/null 2>&1
  hyprctl dispatch layoutmsg "mfact exact 0.5" >/dev/null 2>&1
}

# Ensure $1 is the master of workspace $2 and set 50/50. Robust even when the
# window is already master (no faulty swap).
ensure_master() {
  local addr="$1" ws="$2" cur
  focus_ws "$ws"
  hyprctl dispatch layoutmsg focusmaster >/dev/null 2>&1
  cur="$(hyprctl activewindow -j | jq -r '.address // empty')"
  if [ "$cur" != "$addr" ]; then
    focus_window "$addr"
    hyprctl dispatch layoutmsg swapwithmaster >/dev/null 2>&1
  fi
  master_split_5050
}

# Start an Alacritty in directory $1 and optionally run command $2 in an
# interactive bash (the shell stays open afterwards). Interactive so ~/.bashrc is
# loaded (PATH incl. ~/.nix-profile/bin). Prints the address of the new window;
# returns 1 on timeout.
spawn_alacritty() {
  local dir="$1" innercmd="$2" before
  before="$(addresses_of_class Alacritty)"
  if [ -n "$innercmd" ]; then
    setsid alacritty --working-directory "$dir" -e bash -ic "$innercmd; exec bash" >/dev/null 2>&1 &
  else
    setsid alacritty --working-directory "$dir" >/dev/null 2>&1 &
  fi
  disown
  wait_for_new_window Alacritty "$before"
}

# Open a new zen window with the given zen-browser arguments and print the
# address of the new window. Zen is single-instance, so the window is detected
# via the address diff (a cold start takes longer).
spawn_zen_window() {
  local before
  before="$(addresses_of_class zen)"
  setsid zen-browser "$@" >/dev/null 2>&1 &
  disown
  HYPR_WAIT_TIMEOUT=25 wait_for_new_window zen "$before"
}
