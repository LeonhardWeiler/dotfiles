# dwl

[dwl](https://codeberg.org/dwl/dwl) — a simple, hackable dynamic tiling Wayland
compositor (dwm for Wayland). Added as a lightweight alternative to Hyprland;
Hyprland stays installed and untouched, both show up in the ly login menu.

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
  (`gappih/gappiv/gappoh/gappov` in `config.h`), matching the previous Hyprland
  look (inner 3px, outer 6px).
- `dwl-run` — session entry point (env vars from Hyprland's `env.lua`, then
  `exec dwl -s dwl-autostart`). Symlinked to `/usr/local/bin/dwl-run`.
- `dwl-autostart` — startup commands (mako, wallpaper, sync, battery poll),
  mirrors Hyprland's `autostart.lua`. Symlinked to `/usr/local/bin/dwl-autostart`.
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

## Keybinds (ported from config/hypr/keybinds.lua)

`mainMod` = ALT, same as Hyprland.

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

## Not reproducible 1:1 (dwl vs Hyprland)

dwl is a minimal tiling compositor; a few Hyprland features have no equivalent:

1. **Pixel-exact resize/move of tiled windows** — Hyprland's `ALT+SHIFT+hjkl`
   (resize ±20px) and `ALT+CTRL+SHIFT+hjkl` (move ±20px) don't map onto tiling.
   Only the **horizontal** resize is kept, as master-width (`ALT+SHIFT+H/L` →
   setmfact). Vertical resize and tiled moves are dropped; floating windows can
   still be moved/resized with the mouse (ALT+drag).
2. **"maximized" vs "fullscreen"** — dwl has only one fullscreen mode, so both
   `ALT+M` and `ALT+Z` map to `togglefullscreen`.
3. **Workspaces → tags** — dwl uses tags, not workspaces. ALT+1..6 / ALT+SHIFT+1..6
   behave like workspace switch/move, but tags are a looser model (a window can
   carry several tags; several tags can be viewed at once).
4. **Screenshot tool** — `hyprshot` is Hyprland-only; replaced by
   `grim -g "$(slurp)" - | wl-copy` (grim/slurp/wl-clipboard).
5. **Media keys while locked** — Hyprland bound them with `locked=true`. dwl does
   not dispatch keybinds while the session is locked, so volume/brightness keys
   don't work on the lock screen.
6. **Monitor position** — Hyprland's explicit `HDMI-A-1` at `2560x0` is not copied
   verbatim (dwl x/y are in a different, scaled coordinate space); the external
   output auto-arranges to the right of eDP-1. Set fixed `x/y` in `config.h` if
   needed.
7. **Animations / rounding / blur** — none in dwl (Hyprland had them disabled
   anyway, so no visible change).
8. **hyprlock** — reused as the locker (it speaks the standard ext-session-lock
   protocol, so it should work under dwl); if it ever misbehaves, swap `lockcmd`
   in `config.h` for e.g. `swaylock`.
