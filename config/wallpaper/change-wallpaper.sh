#!/bin/sh
# change-wallpaper - pick a random wallpaper (excluding the previous one) and set
# it via swaybg. Wallpapers live in $WALLPAPER_DIR (default:
# ~/.local/share/wallpapers, where links.conf points config/wallpaper/pictures).
# The "previous" marker is kept in the XDG state dir, not in the repo.

WALLPAPER_DIR="${WALLPAPER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
PREV_WALLPAPER_FILE="$STATE_DIR/change-wallpaper.prev"

if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "wallpaper directory does not exist: $WALLPAPER_DIR" >&2
  exit 1
fi
mkdir -p "$STATE_DIR"

# List all available images, excluding the previous one.
if [ -f "$PREV_WALLPAPER_FILE" ]; then
  PREV_WALLPAPER=$(cat "$PREV_WALLPAPER_FILE")
  WALLPAPER=$(
    find -L "$WALLPAPER_DIR" -type f |
      grep -Fxv "$PREV_WALLPAPER" |
      shuf -n 1
  )
else
  WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f | shuf -n 1)
fi

# If nothing new was found, reshuffle over all images.
[ -z "$WALLPAPER" ] && WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
  echo "no wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

# Stop old swaybg instances, then set the wallpaper.
pkill swaybg
swaybg -i "$WALLPAPER" -m fill &

# Remember the current wallpaper as the previous one.
echo "$WALLPAPER" > "$PREV_WALLPAPER_FILE"
