#!/bin/sh
# SPDX-License-Identifier: ISC
# Copyright (C) 2026 The leonhardweiler/dotfiles Authors

WALLPAPER_DIR="${WALLPAPER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
PREV_WALLPAPER_FILE="$STATE_DIR/change-wallpaper.prev"

if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "wallpaper directory does not exist: $WALLPAPER_DIR" >&2
  exit 1
fi
mkdir -p "$STATE_DIR"

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

[ -z "$WALLPAPER" ] && WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
  echo "no wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

pkill wbg
wbg -s "$WALLPAPER" &

echo "$WALLPAPER" > "$PREV_WALLPAPER_FILE"
