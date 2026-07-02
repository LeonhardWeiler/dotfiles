#!/usr/bin/env bash
# lib_hypr.sh — geteilte Helfer fuer die Hyprland-Workspace-Automatisierung.
# Wird per `source` eingebunden und setzt bash voraus (Arrays, local, Prozess-
# substitution). Alle Fenster werden ueber ihre stabile Adresse angesprochen,
# neue Fenster ueber einen Adress-Diff erkannt (statt ueber fragile Titel).

# --- Konfiguration (per Environment ueberschreibbar) -------------------------
: "${HYPR_WAIT_TIMEOUT:=15}"    # Sekunden, bis das Warten auf ein Fenster aufgibt
: "${HYPR_WAIT_INTERVAL:=0.1}"  # Poll-Intervall in Sekunden

log() { printf '[slf] %s\n' "$*" >&2; }

# Bricht mit Fehlermeldung ab (auch als Rofi-Popup, falls verfuegbar).
die() {
  printf '[slf] FEHLER: %s\n' "$*" >&2
  command -v rofi >/dev/null 2>&1 && rofi -e "SLF-Workspace: $*" >/dev/null 2>&1
  exit 1
}

# Prueft, ob alle benoetigten Kommandos vorhanden sind.
require_cmds() {
  local missing=0 c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || { log "fehlendes Kommando: $c"; missing=1; }
  done
  [ "$missing" -eq 0 ] || die "benoetigte Programme fehlen (siehe Log oben)."
}

# Gibt alle Fenster-Adressen einer Klasse aus (eine pro Zeile).
addresses_of_class() {
  hyprctl clients -j | jq -r --arg c "$1" '.[] | select(.class==$c) | .address'
}

# Wartet, bis eine NEUE Adresse der Klasse $1 erscheint (Diff gegen die in $2
# uebergebene, per Newline getrennte Liste bekannter Adressen) und gibt sie aus.
# Rueckgabe 1 bei Timeout.
wait_for_new_window() {
  local class="$1" before="$2" addr
  local deadline=$(( $(date +%s) + HYPR_WAIT_TIMEOUT ))
  while [ "$(date +%s)" -le "$deadline" ]; do
    while IFS= read -r addr; do
      [ -n "$addr" ] || continue
      case "$before" in
        *"$addr"*) : ;;                      # war schon vorher da
        *) printf '%s\n' "$addr"; return 0 ;; # neu -> zurueckgeben
      esac
    done < <(addresses_of_class "$class")
    sleep "$HYPR_WAIT_INTERVAL"
  done
  return 1
}

# Erste zen-Fenster-Adresse auf einem bestimmten Workspace (leer, wenn keine).
zen_on_ws() {
  hyprctl clients -j \
    | jq -r --argjson w "$1" '.[] | select(.class=="zen" and .workspace.id==$w) | .address' \
    | head -n1
}

# Verschiebt ein Fenster (Adresse) still (ohne Fokuswechsel) auf einen Workspace.
move_window_to_ws() {
  hyprctl dispatch movetoworkspacesilent "$2,address:$1" >/dev/null
}

focus_ws()     { hyprctl dispatch workspace "$1" >/dev/null; }
focus_window() { hyprctl dispatch focuswindow "address:$1" >/dev/null; }

# Setzt fuer den aktuell fokussierten Workspace master-Orientierung links und
# eine 50/50-Aufteilung. Fehler werden geschluckt (Default-mfact ist nah dran).
master_split_5050() {
  hyprctl dispatch layoutmsg orientationleft >/dev/null 2>&1
  hyprctl dispatch layoutmsg "mfact exact 0.5" >/dev/null 2>&1
}

# Stellt sicher, dass $1 der Master von Workspace $2 ist, und setzt 50/50.
# Robust auch dann, wenn das Fenster bereits Master ist (kein Fehl-Swap).
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

# Startet ein Alacritty im Verzeichnis $1 und fuehrt optional den Befehl $2 in
# einer interaktiven Bash aus (danach bleibt die Shell offen). Interaktiv, damit
# ~/.bashrc geladen ist (PATH inkl. ~/.nix-profile/bin). Gibt die Adresse des
# neuen Fensters aus; Rueckgabe 1 bei Timeout.
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

# Oeffnet ein neues zen-Fenster mit den uebergebenen zen-browser-Argumenten und
# gibt die Adresse des neuen Fensters aus. Zen ist single-instance, daher wird
# das Fenster ueber den Adress-Diff erkannt (Cold Start braucht laenger).
spawn_zen_window() {
  local before
  before="$(addresses_of_class zen)"
  setsid zen-browser "$@" >/dev/null 2>&1 &
  disown
  HYPR_WAIT_TIMEOUT=25 wait_for_new_window zen "$before"
}
