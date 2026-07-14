# Changelog

All notable changes to these dotfiles are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Versions before `1.0.0` are pre-release: anything may still change.

## [Unreleased]

### Added

- SPDX license headers (`GPL-3.0-or-later` + copyright) at the top of every own
  script (`install`, `setup/install-programs`, `config/usrbin/*`,
  `change-wallpaper.sh`), so the license travels with a single copied file.

### Changed

- Documentation now says **GNU/Linux** where the whole operating system is meant
  (README, `CLAUDE.md`); "Linux" is kept for the kernel.
- The battery-level check and the login config sync no longer use systemd user
  units. They run as plain commands from the Hyprland autostart
  (`config/hypr/autostart.lua`): a `while` loop calling `bat_check` every 2
  minutes, and `dotfiles_sync` once on login.

### Removed

- The hidden `./install selftest` command and the GitHub Actions CI workflow
  (`.github/workflows/validate.yml`) it fed. `./install validate` is still
  available to check `links.conf` on demand.
- The systemd user units `battery-check.timer`, `battery-check.service` and
  `dotfiles-sync.service` (and their `links.conf`/`services.txt` entries) -
  replaced by the Hyprland autostart commands above.
- The `rofi_keepassxc` launcher script, its `pass` entry in
  `config/hypr/programs.lua` and the `ALT+SHIFT+o` keybind - no longer used.
- The tracked Typst `@local` packages (`config/typst/`, the `school-theme`
  template), its `links.conf` entry and the `~/.local/share/typst/packages`
  symlink. The `typst` package itself stays installed.

### Fixed

- `./install prune` (and the prune step inside `link`/`setup`) aborted before
  writing the `linked-targets` snapshot - and, for `link`, before reactivating
  the systemd units and printing the next steps - whenever it actually pruned a
  stale link, because `prune_stale` returned non-zero under `set -e`. It now
  always returns 0.

## [0.7.0] - 2026-07-14

### Added

- Installer: optional setup steps, selectable from a menu in `./install setup`
  and runnable individually as flags for automation
  (`./install --<step>`): install packages (`--programs`), prune packages not in
  the manifest (`--remove-programs`), enable/disable systemd units
  (`--systemd` / `--remove-systemd`), add the user to groups (`--groups`), set
  the timezone (`--timezone ZONE`), generate locales (`--locale`), deploy the
  ly@tty2 drop-ins (`--ly-dropin`), passwordless sudo for `wheel` (`--sudoers`),
  and rebuild the initramfs (`--initramfs`).
- Non-owner scrub: `./install setup` asks "Are you the repository owner?" and, on
  "no", replaces the personal data in the working copy before linking — git
  identity/signing (`config/git/config`), the restic backup host
  (`config/usrbin/restic-backup`) and the `WLR_DRM_DEVICES` GPU pin
  (`config/hypr/env.lua`). Tri-state `--scrub` / `--no-scrub` (also runnable
  standalone); non-interactively it never scrubs unless asked explicitly.
- `./install validate`: a strict, read-only check of `links.conf`. An
  `optional` third field marks a glob that may legitimately match nothing
  (`config/foo/* ~/dir optional`).
- `--only NAME` / `--exclude NAME` (repeatable) to link/status/unlink/clean only
  a subset of configs (matched on the config dir name).
- `./install prune`: removes links we created whose target was removed or
  retargeted in `links.conf` (e.g. moving `~/.dircolors` to
  `~/.config/dircolors`), recorded in a
  `${XDG_STATE_HOME:-~/.local/state}/dotfiles/linked-targets` snapshot. Runs
  automatically at the end of `link`/`setup`; only symlinks that still resolve
  into the repo are removed, never real files or foreign links.
- Hidden `./install selftest`: links the table into a throwaway `mktemp -d` HOME,
  verifies the symlinks, unlinks and verifies removal - never touching the real
  home.
- CI workflow (`.github/workflows/validate.yml`) running the installer's syntax
  check, `validate` and `selftest` on every push / PR.
- This `CHANGELOG.md`.

### Changed

- XDG Base Directory compliance: bash history moved to
  `$XDG_STATE_HOME/bash/history` (was `~/.config/bash/.bash_history`), the
  dircolors config to `~/.config/dircolors` (was the bare `~/.dircolors`), git
  now reads its native `~/.config/git/config` (renamed from `.gitconfig`,
  dropping the `GIT_CONFIG_GLOBAL` override in `.bashrc` and the sync service),
  and typst `@local` packages link into `~/.local/share/typst/packages` (was
  pinned under `~/.config` via `TYPST_PACKAGE_PATH`).
- `./install setup` now presents a menu of optional steps instead of always
  running a fixed sequence and printing a manual checklist.
- `links.conf` handling is now a strict `parse -> validate -> build -> execute`
  pipeline: every command validates first and **aborts on any problem** (nothing
  changed) with `links.conf:<line>: <msg>`, instead of warning and continuing.
  Checks: missing target, stray fields, absolute/escaping/non-existent source,
  duplicate source or target, a target outside `~` / `/etc` / `/usr/local`, and
  an unmatched glob.
- Converted the helper scripts to POSIX `#!/bin/sh` where feasible (`vol_ctl`,
  `bright_ctl`, `bat_check`, `restic-backup`, `dotfiles_sync`,
  `setup/install-programs`); `install` and `update_programs_list` stay Bash on
  purpose (associative arrays / process substitution).
- Battery indicator (`.bashrc`, `bat_check`) now auto-detects the battery by
  type instead of assuming `BAT0` (works for `BAT1`/`CMB0`/…).
- `WLR_DRM_DEVICES` (`config/hypr/env.lua`) pins the integrated GPU for the owner
  and is removed by the scrub on other machines (wlroots then auto-detects).
- The systemd unit lists, the group list and the font packages are now read from
  `setup/services.txt`, `setup/groups.txt` and `setup/fonts.txt` instead of being
  hardcoded in `install`.

### Removed

- The Rofi workspace launcher (`rofi_workspace_manager`, `workspace_slf`,
  `lib_hypr.sh`) and its `ALT+W` keybind.

## [0.6.0] - 2026-07-08

### Added

- Neovim: C#/Unity support (Roslyn LSP, csharpier formatter, Treesitter).

## [0.5.0] - 2026-07-05

### Added

- `./install setup`: one-command bootstrap for a fresh machine (install packages,
  link configs with `--force`, activate units).
- ly@tty2 login-manager drop-ins (`wait-home.conf`, `keymap.conf`).

### Changed

- Renamed `scripts/` to `setup/` and moved `links.conf` into it; dropped the
  `.sh` extensions from the deployment scripts.
- Folded package installation into `setup` (removed the separate `--programs`
  switch).
- Package-list logic consolidated into `update_programs_list`; the yay bootstrap
  uses `mktemp -d` instead of a fixed `/tmp/yay`.
- `ly` session log moved to the XDG state dir instead of `~/ly-session.log`.

## [0.4.0] - 2026-07-05

### Added

- Own dependency-free symlink manager (`./install`) driven by `setup/links.conf`,
  replacing dotbot.
- `--force` (back up real targets to `.bak` before linking), `clean` (remove
  those backups), `status`, and glob sources (`config/usrbin/*`) for per-file
  linking into a directory that stays real.
- Track more `/etc` configs: `vconsole`, `locale`, `locale.gen`, `pacman`,
  `logind`.

### Changed

- systemd units are activated with `enable` instead of `reenable` (avoids
  deleting the linked-unit symlink); `SYSTEM_UNITS` reduced to units that really
  exist.
- pacman hook made portable via `/usr/local/bin/update_programs_list`.

### Fixed

- `link_one` handles a dead symlink as a parent path instead of aborting.

## [0.3.0] - 2026-07-03

### Added

- Track `mkinitcpio.conf`, Claude Code skills/`settings.json`, and btop/qt5ct/
  pipewire/mimeapps configs.
- Automatic `programs.txt` maintenance (pacman hook) and config sync on login
  (`dotfiles-sync.service`).

### Changed

- Restructured the repo into `config/` + `scripts/` with flat source paths.
- Moved the personal scripts to `~/.local/bin`.
- Relocated GOPATH and the npm cache to XDG paths; made `restic-backup` and
  `update_programs_list` user/home-agnostic.

## [0.2.0] - 2026-07-02

### Added

- Neovim overhaul: `blink.cmp`, `mini.*`, `conform.nvim` (format-on-save),
  `nvim-lint`, an expanded LSP setup (mason 2.x), and Treesitter tuning.

### Changed

- Migrated the Hyprland config from hyprlang to Lua (later split into thematic
  modules).

## [0.1.0] - 2026-07-02

### Added

- Initial public dotfiles for Arch Linux with Hyprland: Alacritty, Bash, btop,
  Git, Hyprland, Neovim, Rofi, Mako, MPV, and the personal helper scripts.

[Unreleased]: https://github.com/leonhardweiler/dotfiles/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/leonhardweiler/dotfiles/releases/tag/v0.1.0
