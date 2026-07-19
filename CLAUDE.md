# CLAUDE.md

Notes for working on this dotfiles repo. Comment/doc language: **English**.

## Overview

Personal dotfiles for Arch GNU/Linux with dwl (Wayland), managed via a **custom,
dependency-free symlink script** (`./install`, plain Bash). The repo root
separates **`config/`** (the config sources, **flat**: `config/<name>/…`) from
**`setup/`** (deployment machinery: link map, package manifest, bootstrap
scripts). The source->target mapping is stated explicitly in
**`setup/links.conf`** (one line per link, two columns: `<source-in-repo> <target>`;
`~` targets = user, `/etc/…` targets = system via sudo). Examples:
`config/btop/btop.conf` -> `~/.config/btop/btop.conf`,
`config/ly/config.ini` -> `/etc/ly/config.ini`. Details on contents/paths:
`README.md`. No external dependencies (no Python, no dotbot).

## Installation & commands

- **Linking**: `./install` (= `./install link`) - creates/refreshes all links
  from `links.conf` and then reactivates the systemd units (self-healing). `~/…`
  targets without, `/etc/…` targets via sudo (asks for the password if needed).
  Options: `--user-only` (only `~`, no sudo), `--no-units` (skip systemd),
  `-n/--dry-run` (only show), `--force` (back up a real file/dir at the target to
  `.bak` and replace it - otherwise real targets stay protected; existing
  symlinks are replaced anyway).
- **New machine (bootstrap, one command)**: `./install setup` - shows a **menu of
  optional steps** (on a TTY; Enter = defaults, without a TTY the defaults run),
  then links the configs (implies `--force`) and runs the chosen steps. `link`
  stays the idempotent everyday refresh; `setup` wraps the first-time setup flow.
- **Optional setup steps** (selectable in the `setup` menu, **runnable
  individually via a flag** - `./install --<step>` runs only those steps without
  linking; `./install setup --<step> …` skips the menu and selects exactly
  those). Registry in the script: `register_step <name> <fn> "<description>"`,
  `DEFAULT_STEPS` = menu preselection:
  - `--programs` - install packages from `programs.txt` (delegates to
    `setup/install-programs`, bootstraps yay). *Default.*
  - `--systemd` - activate user/system units (`reactivate_units`). *Default.*
  - `--groups` - add the user to the groups from `setup/groups.txt` (loaded into
    `GROUP_LIST`) via `usermod -aG`.
  - `--timezone ZONE` - set `/etc/localtime` (without `ZONE` the menu asks).
  - `--locale` - `locale-gen`. *Default.*
  - `--ly-dropin` - deploy the ly@tty2 drop-ins as **real copies** to `/etc`.
  - `--sudoers` - passwordless sudo for `wheel` (`/etc/sudoers.d/`, validated
    with `visudo -c`).
  - `--initramfs` - `mkinitcpio -P`.
  - `--fonts` - install the font packages from `setup/fonts.txt` (loaded into
    `FONT_PACKAGES`) and rebuild the fontconfig cache (`fc-cache -f`).
  - `--dwl` - build + install **dwl** (Wayland compositor, compiled config) from
    `config/dwl/config.h` via `config/dwl/build-dwl` (clone/pin dwl, drop in
    `config.h`, `make`, install the binary to `/usr/local/bin/dwl`). Since dwl is
    configured at compile time, this is the **apply** step for `config/dwl`
    changes. Not a default step.
- **Removing**: `./install unlink` - removes the symlinks we manage (only real
  symlinks to our sources; real files/foreign links stay).
- **Status**: `./install status` - shows per entry ok / foreign link / real file
  / missing.
- **Validating `links.conf`**: `./install validate` - read-only check (no
  filesystem changes). The `links.conf` pipeline is **parse -> validate -> build
  (globs) -> execute**, and **every** command validates first, so a broken config
  aborts the whole run (nothing changed) instead of silently skipping lines.
  Validation is fatal, reporting `links.conf:<line>: <msg>` for:
  missing target, stray extra field (only a third `optional` keyword is allowed),
  absolute source, non-existent source, duplicate (expanded) target, a target
  outside the allowlist (`ALLOWED_TARGET_PREFIXES` = `~` / `/etc` / `/usr/local`),
  and a glob that matches nothing. Mark a legitimately-empty glob with a third
  `optional` field: `config/foo/* ~/dir optional`.
- **Update the package list** (without re-linking): `update_programs_list` (from
  `config/usrbin/`, on the PATH; the same script the pacman hook uses).
- **Install packages from `programs.txt`**: `./setup/install-programs` (uses `yay`).
- **Check shell scripts** (no test framework): syntax with `bash -n <script>`
  (or `sh -n` for the `#!/bin/sh` scripts); where available `shellcheck
  <script>`. Most scripts are POSIX `#!/bin/sh`; only `install` and
  `config/usrbin/update_programs_list` are intentionally `bash` (associative
  arrays / process substitution) - keep new bashisms out of the `sh` scripts.

## Structure

- **`config/`** = flat config sources: `bash`, `btop`, `claude`,
  `dwl`, `foot`, `git`, `hyprlock`, `keepassxc`, `locale`, `logind`, `ly`, `mako`, `mimeapps`,
  `mkinitcpio`, `mpv`, `nvim`, `pacman`, `pipewire`, `qt5ct`, `rofi`,
  `systemd-system`, `usrbin`, `vconsole`, `wallpaper`.
  Whole directories are linked as a dir symlink (foot, nvim, rofi,
  mako, mpv, git, keepassxc); for `btop`/`qt5ct`/`pipewire`/`mimeapps`/
  `claude`/`hyprlock` and `/etc` targets deliberately **only the single file**
  is linked (parent directory stays real - app runtime, or to avoid hiding system
  contents). `usrbin` is linked **per file via a glob** (`config/usrbin/*`) into
  `~/.local/bin` so the directory stays real and foreign entries (e.g. `claude`)
  are preserved. `claude` does **not** track
  `.claude.json`/sessions/history/cache (auth/state/secrets).
- **`setup/`** = deployment machinery: `links.conf` (link map, default config of
  `./install`), `programs.txt` (package manifest), `install-programs` (bootstrap
  script, without a `.sh` extension), and the **data lists the installer reads
  instead of hardcoding them**: `services.txt` (systemd units, `<scope> <unit>`
  -> `USER_UNITS`/`SYSTEM_UNITS`), `groups.txt` (-> `GROUP_LIST`) and `fonts.txt`
  (-> `FONT_PACKAGES`). The old `install.sh`/`migrate.sh` is replaced by
  `./install` + `setup/links.conf`. The package list itself is written by
  `config/usrbin/update_programs_list` (the single source, also used by the
  pacman hook).
- **`/etc` targets** (in `links.conf`, per file, `/etc/…` target path):
  `ly/config.ini`, `mkinitcpio.conf`,
  `systemd-system/legion-conservation.service`,
  `pacman/dotfiles-programs-list.hook`, `vconsole/vconsole.conf`,
  `locale/locale.conf`, `locale/locale.gen` (-> `/etc/locale.gen`),
  `pacman/pacman.conf` (-> `/etc/pacman.conf`),
  `logind/logind.conf` (-> `/etc/systemd/logind.conf`).
- **System services**: activated by the `install` script after linking via
  `systemctl enable` - the unit lists live in `setup/services.txt` (loaded into
  `USER_UNITS` / `SYSTEM_UNITS`). There are currently **no `user` units**: the
  battery-level check and the config sync run as plain commands from the dwl
  autostart (`autostart[]` in `config/dwl/config.h`) instead of systemd user units
  (a `while` loop calling `bat_check` every 2 min, and `dotfiles_sync` once on login).
  Deliberately `enable`, **not**
  `reenable`: our unit files are symlinks (linked units), and `reenable` would
  delete exactly that unit symlink during its internal `disable`. `SYSTEM_UNITS`
  only contains system units that really exist - pipewire/wireplumber (user
  scope) and swtpm (socket-activated) are **not** in it.
  PipeWire/WirePlumber/figma-agent come from their package presets and are
  **not** tracked (formerly `*.wants` links in the repo - now removed).
- **Not linked**: `AGENT/` (work/workflow files) stays in the repo root.
- Custom scripts: **`config/usrbin/*`** -> `~/.local/bin` (per file, on the
  `PATH` via `.bashrc`). `dotfiles_sync` versions
  `setup/programs.txt`; `update_programs_list` writes there.
  `update_programs_list` is **additionally** linked to the fixed system path
  `/usr/local/bin/update_programs_list` (its own `links.conf` line), because the
  pacman hook (`/etc/pacman.d/hooks`) knows no `$HOME` variables and calls it from
  there - so the hook stays portable for a foreign user too.
- **`config/wallpaper/`** = the picture set (`pictures/`, linked as a dir symlink
  to `~/.local/share/wallpapers`) plus `change-wallpaper.sh` (linked to
  `~/.local/bin/change-wallpaper`, picks a random wallpaper via swaybg; called
  from the dwl autostart in `config/dwl/config.h`). The script defaults to
  `~/.local/share/wallpapers`, so both link targets line up.
- **`nvim/`** has its **own `CLAUDE.md`** (`config/nvim/CLAUDE.md`) with the
  nvim-specific verification commands - for nvim changes look there.

## Conventions & pitfalls

- New config: put the file **flat under `config/<name>/`** and add a line
  `<source-in-repo>  <target>` to `setup/links.conf`. `/etc` targets **always per
  file** (full `/etc/…` target path), never whole directories. If a target
  directory should stay real and only individual files inside it be linked, let
  the source end in `/*` (glob; links each entry into `<target>/<name>`) - see
  `config/usrbin/*`.
- **`AGENT/` stays in the root** and outside the link logic.
- **Scaling/cursor env** (QT_SCALE_FACTOR, GDK_SCALE, XCURSOR_SIZE, …) are set
  exclusively in the dwl session wrapper `config/dwl/dwl-run`, **not** in `.bashrc`
  - do not duplicate them (otherwise apps render differently depending on how
  they were launched).
- **hyprlock** (`config/hyprlock/hyprlock.conf`) is kept as the dwl screen locker
  (dwl's `lockcmd` in `config.h`). It reads `~/.config/hypr/hyprlock.conf`, so the
  file is linked there per-file (the `~/.config/hypr` directory itself stays real -
  Hyprland and its `config/hypr` Lua config have been removed).
- **dwl** (`config/dwl/`) is the Wayland compositor (it replaced Hyprland, which
  has been removed). Unlike everything else here it
  is **configured at compile time**: `config/dwl/config.h` is the source of truth
  and is **not** symlinked - it is compiled into the binary. Editing it means
  rebuilding (`./install --dwl`). Only the session glue is symlinked
  (`dwl.desktop`, `dwl-run`, `dwl-autostart` -> `/usr/local/…`). ly finds the
  session via the extra `waylandsessions` path in `config/ly/config.ini`. Gaps
  (like Hyprland's) come from `config/dwl/patches/gaps.patch`, applied by
  `build-dwl` on top of the pinned checkout. See `config/dwl/README.md` for the
  Hyprland->dwl port and what could not be reproduced 1:1 (pixel-exact tiled
  resize/move, workspaces vs tags, …).
- **KeePassXC DB** (`*.kdbx`) is excluded via `.gitignore` and the
  `config/keepassxc/` folder via `.claudeignore`.
- Commits are SSH-signed (`config/git/config`).
- Scripts carry a two-line license header right after the shebang:
  `# SPDX-License-Identifier: ISC` + a `# Copyright (C) <year> The
  leonhardweiler/dotfiles Authors` line (the repo is ISC, see `LICENSE`). Add it to any new script so the
  license travels with a single copied file. Third-party scripts (e.g.
  `config/mpv/scripts/thumbfast.lua`) keep their own header.
- Two health/workflow skills write into `AGENT/`: `review-and-update-report`
  (health report) and `implement-todo` (work through `TODO.md`, one commit per
  item).
