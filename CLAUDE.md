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
`config/mkinitcpio/mkinitcpio.conf` -> `/etc/mkinitcpio.conf`. Details on contents/paths:
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
  those). Registry in the script:
  `register_step <name> <fn> "<description>" [<arg-placeholder>]` - it is the
  **single source of truth**: the `--<name>` flag is matched generically against
  it during argument parsing (which therefore sits *below* the `register_step`
  calls) and `--help` generates the step list from `STEP_ORDER`/`STEP_DESC`, so
  adding a step is one `register_step` call and nothing else. The optional 4th
  field names the value a flag takes (only `--timezone ZONE` has one).
  `DEFAULT_STEPS` = menu preselection:
  - `--programs` - install packages from `programs.txt` (delegates to
    `setup/install-programs`, bootstraps yay). _Default._
  - `--systemd` - activate user/system units (`reactivate_units`). _Default._
  - `--groups` - add the user to the groups from `setup/groups.txt` (loaded into
    `GROUP_LIST`) via `usermod -aG`.
  - `--timezone ZONE` - set `/etc/localtime` (without `ZONE` the menu asks).
  - `--locale` - `locale-gen`. _Default._
  - `--getty-autologin` - deploy the getty@tty1 autologin drop-in as a **real
    copy** to `/etc`. There is no display manager: `getty@tty1` is overridden to
    log `leo` in automatically (`agetty --autologin`), and `~/.bash_profile` then
    execs the dwl session on tty1. Real copy (not symlinked) for the same reason
    the ly drop-ins were - systemd reads unit drop-ins before `/home` is mounted.
  - `--sudoers` - passwordless sudo for `wheel` (`/etc/sudoers.d/`, validated
    with `visudo -c`).
  - `--initramfs` - `mkinitcpio -P`.
  - `--legion-conservation` - enable the Lenovo Legion battery conservation mode
    (write `1` to the `ideapad_acpi` `conservation_mode` sysfs entry). **One-shot**,
    not a boot-time job: the driver writes the flag through to the embedded
    controller, which keeps it across reboots. Idempotent (no-op when already
    set) and self-skipping when the sysfs entry is missing. Not a default step.
  - `--fonts` - install the font packages from `setup/fonts.txt` (loaded into
    `FONT_PACKAGES`) and rebuild the fontconfig cache (`fc-cache -f`).
  - `--dwl` - build + install **dwl** (Wayland compositor, compiled config) from
    `config/dwl/config.h` via `config/dwl/build-dwl` (clone/pin dwl, drop in
    `config.h`, `make`, install the binary to `/usr/local/bin/dwl`). Since dwl is
    configured at compile time, this is the **apply** step for `config/dwl`
    changes. Not a default step.
  - `--wbg` - build + install **wbg** (the wallpaper program) from a pinned
    upstream tag via `config/wbg/build-wbg` (clone/pin wbg,
    `meson`/`ninja`, install the binary to `/usr/local/bin/wbg`; installs
    `tllist` from the AUR via yay). Built **jpg-only** (meson feature flags
    disable png/webp/jxl/svg) since all wallpapers are jpg - that is the reason
    it is built from source rather than installed from the AUR `wbg` package
    (which enables every format). Like dwl, the source is cloned at build time
    (not committed) and only the binary is installed. Not a default step.
    **Currently stood down**: wbg + the whole wallpaper feature are disabled
    (nothing installed/linked/autostarted) - the `config/wbg/` build script and
    `config/wallpaper/pictures` stay in the repo so it can be brought back. To
    re-enable: uncomment the two wallpaper lines in `setup/links.conf` and the
    `change-wallpaper` autostart line in `config/dwl/config.h` (then
    `./install --dwl`), and run `./install --wbg`.
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
- **Install packages from `programs.txt`**: `./setup/install-programs` (uses
  `yay`). A package that fails is collected and reported at the end instead of
  aborting the run; the list is read on FD 3 so yay cannot eat it off stdin.
- **Check shell scripts** (no test framework): syntax with `bash -n <script>`
  (or `sh -n` for the `#!/bin/sh` scripts); where available `shellcheck
  <script>`. Most scripts are POSIX `#!/bin/sh`; only `install` and
  `config/usrbin/update_programs_list` are intentionally `bash` (associative
  arrays / process substitution) - keep new bashisms out of the `sh` scripts.
  
  
  
  
  
  
  
  
  


## Structure

- **`config/`** = flat config sources: `bash`, `btop`, `claude`,
  `dwl`, `foot`, `git`, `keepassxc`, `locale`, `logind`, `mimeapps`,
  `mkinitcpio`, `mpv`, `nvim`, `pacman`, `pipewire`, `qt5ct`, `rofi`,
  `systemd-system`, `usrbin`, `wallpaper`, `wbg`, `wob`.
  Whole directories are linked as a dir symlink (foot, nvim, rofi,
  wob, mpv, git, keepassxc); for `btop`/`qt5ct`/`pipewire`/`mimeapps`/
  `claude` and `/etc` targets deliberately **only the single file**
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
  `mkinitcpio.conf`,
  `pacman/dotfiles-programs-list.hook`,
  `locale/locale.conf`, `locale/locale.gen` (-> `/etc/locale.gen`),
  `pacman/pacman.conf` (-> `/etc/pacman.conf`),
  `logind/logind.conf` (-> `/etc/systemd/logind.conf`).
  There is **no** `config/vconsole/`: `/etc/vconsole.conf` is left as the
  untouched systemd fallback, `systemd-vconsole-setup.service` is `mask`ed in
  `services.txt`, and the `keymap`/`consolefont` hooks are gone from `HOOKS` in
  `mkinitcpio.conf`. The TTY therefore runs plain `us` QWERTY - accepted
  knowingly (autologin, no password typed on the VT).
- **System services**: activated by the `install` script after linking via
  `systemctl enable` - the unit lists live in `setup/services.txt` (loaded into
  `USER_UNITS` / `SYSTEM_UNITS`). There are currently **no `user` units**: the
  battery-level check runs as a plain command from the dwl
  autostart (`autostart[]` in `config/dwl/config.h`) instead of a systemd user unit
  (a `while` loop calling `bat_check` every 2 min).
  Deliberately `enable`, **not**
  `reenable`: our unit files are symlinks (linked units), and `reenable` would
  delete exactly that unit symlink during its internal `disable`. `SYSTEM_UNITS`
  only contains system units that really exist - pipewire/wireplumber (user
  scope) and swtpm (socket-activated) are **not** in it.
  PipeWire/WirePlumber/figma-agent come from their package presets and are
  **not** tracked (formerly `*.wants` links in the repo - now removed).
  There is also no `legion-conservation.service` any more: the ideapad
  `conservation_mode` flag persists in the embedded controller, so it is set
  once via the `--legion-conservation` step instead of at every boot.
- **Not linked**: `AGENT/` (work/workflow files) stays in the repo root.
- Custom scripts: **`config/usrbin/*`** -> `~/.local/bin` (per file, on the
  `PATH` via `.bashrc`). `update_programs_list` writes
  `setup/programs.txt`.
  `update_programs_list` is **additionally** linked to the fixed system path
  `/usr/local/bin/update_programs_list` (its own `links.conf` line), because the
  pacman hook (`/etc/pacman.d/hooks`) knows no `$HOME` variables and calls it from
  there - so the hook stays portable for a foreign user too.
- **`config/wallpaper/`** = the picture set (`pictures/`, linked as a dir symlink
  to `~/.local/share/wallpapers`) plus `change-wallpaper.sh` (linked to
  `~/.local/bin/change-wallpaper`, picks a random wallpaper via wbg; called
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
- **waylock** is the dwl screen locker (dwl's `lockcmd` in `config.h`), replacing
  the former hyprlock. It has **no config file** - everything is CLI flags, so
  there is no `config/waylock/` and no `links.conf` entry; the configuration is
  the `lockcmd[]` array in `config/dwl/config.h` and changing it needs
  `./install --dwl`. waylock only paints solid colors, so hyprlock's screenshot
  background, blur, input field, `hide_cursor` and `fail_timeout` have no
  equivalent (see README "Screen locker").
- **dwl** (`config/dwl/`) is the Wayland compositor. Unlike everything else here it
  is **configured at compile time**: `config/dwl/config.h` is the source of truth
  and is **not** symlinked - it is compiled into the binary. Editing it means
  rebuilding (`./install --dwl`), and the new binary only takes effect in a
  **new** session. There is **no display manager**: `getty@tty1` autologins
  `leo` and `~/.bash_profile` execs `dwl` on tty1 (see the `--getty-autologin`
  step). `build-dwl` applies **every** `config/dwl/patches/*.patch` on top of
  the pinned checkout - currently three, all user-visible:
  `attachbottom.patch` (new windows attach at the bottom of the stack),
  `autostart.patch` (enables the `autostart[]` array in `config.h`, which is how
  startup programs are spawned - there is no session script) and `gaps.patch`
  (inner/outer gaps in the `tile` layout). `MODKEY` is **Alt**, there are **9
  tags**, and `AGENT/keybinds.md` lists every binding on the system (snapshot -
  `config.h` stays the authority). `build-dwl` only contacts the remote when the
  pinned tag is missing locally, so an outage cannot block applying a `config.h`
  change.
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
  item). `AGENT/keybinds.md` is a hand-kept overview of every keybinding on the
  system - update it when a binding changes.
- **Claude Code runs without permission prompts here, on purpose**: `.bashrc`
  aliases `claude` to `claude --dangerously-skip-permissions` and
  `config/claude/settings.json` sets `skipDangerousModePermissionPrompt`.
  Together with the passwordless `wheel` sudo from `--sudoers` that means no
  guard rails at all - documented in the README, and the alias is meant to stay
  the command.
