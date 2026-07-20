# wbg

[wbg](https://codeberg.org/dnkl/wbg) — a minimal wallpaper program for
wlroots-based Wayland compositors (layer-shell). It is the wallpaper backend for
the dwl session and has **no runtime config**: it takes a single image path and
scales it to fill the output.

wbg is available in the AUR, but that package builds with every image format
enabled. We only use jpg wallpapers, so `build-wbg` builds it **jpg-only** from a
pinned upstream tag (1.3.0) — cloned at build time into `~/.local/src/wbg` (not
committed), only the binary installed. That drops the png/webp/jxl/svg deps and
leaves libjpeg-turbo as the sole image dep (plus `tllist` from the AUR).

## Build / apply

```sh
./install --wbg
```

Or directly:

```sh
config/wbg/build-wbg
```

## Usage

wbg is not started directly; the session sets the wallpaper through
`config/wallpaper/change-wallpaper.sh` (linked to `~/.local/bin/change-wallpaper`,
called from `autostart[]` in `config/dwl/config.h`). That script picks a random
image and runs `wbg <image>`, killing any previous instance first.
