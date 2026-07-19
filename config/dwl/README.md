# dwl

[dwl](https://codeberg.org/dwl/dwl) — a simple, hackable dynamic tiling Wayland
compositor (dwm for Wayland).

dwl is configured at **compile time** (suckless style): there is no runtime
config file. The tracked source of truth is **`config.h`**; changing behaviour
means editing it and rebuilding.

## Files

- `config.h` — the ported configuration (keybinds, monitors, input, colors).
  The one file to edit. **Not** symlinked — it is compiled in.
- `build-dwl` — clone/pin dwl (v0.8), reset to a pristine checkout, apply
  `patches/*.patch`, drop in `config.h`, `make`, install the binary to
  `/usr/local/bin/dwl`. Deliberately installs **only the binary** (not
  `make install`, which would overwrite the session file below).
- `patches/gaps.patch` — adds inner/outer gaps to the `tile` layout
  (`gappih/gappiv/gappoh/gappov` in `config.h`)
- `dwl-run` — session entry point: exports the scaling/cursor env, then
  `exec dwl`. Symlinked to `/usr/local/bin/dwl-run`. (XDG_CURRENT_DESKTOP and the
  Qt platform theme come from `~/.bash_profile`, sourced by ly's login shell.)
- Startup programs (mako, wallpaper, sync, battery poll) are spawned by dwl
  itself via the `autostart[]` array in `config.h` (enabled by
  `patches/autostart.patch`) — there is no separate autostart script.
- `dwl.desktop` — the ly/wayland session entry (`Exec=dwl-run`). Symlinked to
  `/usr/local/share/wayland-sessions/dwl.desktop` (ly reads that path via the
  extra `waylandsessions` line in `config/ly/config.ini`).

## Build / apply changes

```sh
./install --dwl      # build + install (also part of `./install setup` menu)
# or directly:
config/dwl/build-dwl
```

`./install` (link) sets up the symlinks; `./install --dwl` compiles and installs
the binary. Log out and pick **dwl** in ly.

## Keybinds

`mainMod` = ALT

| Action                        | dwl bind                  |
| ----------------------------- | ------------------------- |
| Terminal (foot)               | ALT+SHIFT+Return          |
| Close window                  | ALT+SHIFT+C               |
| Quit dwl                      | ALT+SHIFT+Q               |
| Toggle floating               | ALT+V                     |
| Menu (rofi drun)              | ALT+SHIFT+P               |
| Filebrowser (rofi)            | ALT+SHIFT+T               |
| Browser (zen-browser)         | ALT+SHIFT+N               |
| Lock (hyprlock)               | SUPER+L                   |
| Focus next / prev             | ALT+J / ALT+K             |
| Swap with master              | ALT+Return                |
| Fullscreen / "maximized"      | ALT+Z / ALT+M             |
| Master width −/+              | ALT+SHIFT+H / ALT+SHIFT+L |
| Workspace/tag 1–6             | ALT+1..6                  |
| Move window to tag 1–6        | ALT+SHIFT+1..6            |
| Volume up/down/mute           | ALT+F3 / ALT+F2 / ALT+F1  |
| Brightness up/down            | ALT+F6 / ALT+F5           |
| Screenshot region → clipboard | Print                     |
| Move / resize with mouse      | ALT+drag / ALT+right-drag |
