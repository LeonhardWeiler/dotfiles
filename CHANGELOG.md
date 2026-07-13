# Changelog

All notable changes to these dotfiles are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Versions before `1.0.0` are pre-release: anything may still change.

## [Unreleased]

### Added

- Installer: optional setup steps, selectable from a menu in `./install setup`
  and runnable individually as flags for automation
  (`./install --<step>`): install packages (`--programs`), prune packages not in
  the manifest (`--remove-programs`), enable/disable systemd units
  (`--systemd` / `--remove-systemd`), add the user to groups (`--groups`), set
  the timezone (`--timezone ZONE`), generate locales (`--locale`), deploy the
  ly@tty2 drop-ins (`--ly-dropin`), passwordless sudo for `wheel` (`--sudoers`),
  and rebuild the initramfs (`--initramfs`).
- This `CHANGELOG.md`.

### Changed

- `./install setup` now presents a menu of optional steps instead of always
  running a fixed sequence and printing a manual checklist.

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

[Unreleased]: https://github.com/leonhardweiler/dotfiles/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/leonhardweiler/dotfiles/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/leonhardweiler/dotfiles/releases/tag/v0.1.0
