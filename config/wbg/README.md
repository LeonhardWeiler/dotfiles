# wbg

[wbg](https://codeberg.org/dnkl/wbg) — a minimal wallpaper program for
wlroots-based Wayland compositors (layer-shell). It is the wallpaper backend for
the dwl session.

wbg has **no runtime config**: it takes a single image path and scales it to
fill the output. Like dwl, it is built from a **pinned upstream tag** cloned at
build time into `~/.local/src/wbg` (not committed to this repo); only the binary
is installed.

## Files

- `build-wbg` — clone/pin wbg (1.3.0), reset to a pristine checkout, `meson` +
  `ninja` build, install **only the binary** to `/usr/local/bin/wbg`. Installs
  the official-repo deps via pacman and `tllist` (AUR) via yay.

## Build / apply

```sh
./install --wbg      # build + install (also part of the `./install setup` menu)
# or directly:
config/wbg/build-wbg
```

## Usage

wbg is not started directly; the session sets the wallpaper through
`config/wallpaper/change-wallpaper.sh` (linked to `~/.local/bin/change-wallpaper`,
called from `autostart[]` in `config/dwl/config.h`). That script picks a random
image and runs `wbg <image>`, killing any previous instance first.
