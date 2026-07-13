# CLAUDE.md

Notes for working on this dotfiles repo. Comment/doc language: **English**.

## Overview

Personal dotfiles for Arch Linux with Hyprland (Wayland), managed via a **custom,
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
  - `--remove-programs` - remove explicitly installed packages that are **not**
    in the manifest (`pacman -Rns`, with a prompt; prune to the package list).
  - `--systemd` - activate user/system units (`reactivate_units`). *Default.*
  - `--remove-systemd` - deactivate those same units (prompt; note: linked units
    are removed in the process).
  - `--groups` - add the user to `GROUP_LIST` via `usermod -aG`.
  - `--timezone ZONE` - set `/etc/localtime` (without `ZONE` the menu asks).
  - `--locale` - `locale-gen`. *Default.*
  - `--ly-dropin` - deploy the ly@tty2 drop-ins as **real copies** to `/etc`.
  - `--sudoers` - passwordless sudo for `wheel` (`/etc/sudoers.d/`, validated
    with `visudo -c`).
  - `--initramfs` - `mkinitcpio -P`.
  - `--fonts` - install the font packages (`FONT_PACKAGES`: noto-fonts{,-cjk,
    -emoji}, ttf-jetbrains-mono-nerd) and rebuild the fontconfig cache
    (`fc-cache -f`).
- **Removing**: `./install unlink` - removes the symlinks we manage (only real
  symlinks to our sources; real files/foreign links stay).
- **Status**: `./install status` - shows per entry ok / foreign link / real file
  / missing.
- **Cleaning backups**: `./install clean` - deletes the `.bak` backups of the
  managed targets that `--force` created (incl. `*.bak.<timestamp>`; foreign
  `.bak` are left untouched). Preview with `-n`.
- **Update the package list** (without re-linking): `update_programs_list` (from
  `config/usrbin/`, on the PATH; the same script the pacman hook uses).
- **Install packages from `programs.txt`**: `./setup/install-programs` (uses `yay`).
- **Check shell scripts** (no test framework): `bash -n <script>`; where
  available `shellcheck <script>`.

## Structure

- **`config/`** = flat config sources: `alacritty`, `bash`, `btop`, `claude`,
  `git`, `hypr`, `keepassxc`, `locale`, `logind`, `ly`, `mako`, `mimeapps`,
  `mkinitcpio`, `mpv`, `nvim`, `pacman`, `pipewire`, `qt5ct`, `rofi`,
  `systemd-system`, `systemd-user`, `typst`, `usrbin`, `vconsole`. Whole
  directories are linked as a dir symlink (alacritty, hypr, nvim, rofi,
  mako, mpv, git, typst, keepassxc); for `btop`/`qt5ct`/`pipewire`/`mimeapps`/
  `claude` and `systemd-user`/`/etc` targets deliberately **only the single file**
  is linked (parent directory stays real - app runtime, or to avoid hiding system
  contents). `usrbin` is linked **per file via a glob** (`config/usrbin/*`) into
  `~/.local/bin` so the directory stays real and foreign entries (e.g. `claude`)
  are preserved. `claude` does **not** track
  `.claude.json`/sessions/history/cache (auth/state/secrets).
- **`setup/`** = deployment machinery: `links.conf` (link map, default config of
  `./install`), `programs.txt` (package manifest), `install-programs` (bootstrap
  script, without a `.sh` extension). The old `install.sh`/`migrate.sh` is
  replaced by `./install` + `setup/links.conf`. The package list itself is
  written by `config/usrbin/update_programs_list` (the single source, also used
  by the pacman hook).
- **`/etc` targets** (in `links.conf`, per file, `/etc/…` target path):
  `ly/config.ini`, `mkinitcpio.conf`,
  `systemd-system/legion-conservation.service`,
  `pacman/dotfiles-programs-list.hook`, `vconsole/vconsole.conf`,
  `locale/locale.conf`, `locale/locale.gen` (-> `/etc/locale.gen`),
  `pacman/pacman.conf` (-> `/etc/pacman.conf`),
  `logind/logind.conf` (-> `/etc/systemd/logind.conf`).
- **System/user services**: activated by the `install` script after linking via
  `systemctl enable` (system) or `systemctl --user enable` (user:
  `battery-check.timer`, `dotfiles-sync.service`) - the unit lists are at the top
  of the script (`USER_UNITS` / `SYSTEM_UNITS`). Deliberately `enable`, **not**
  `reenable`: our unit files are symlinks (linked units), and `reenable` would
  delete exactly that unit symlink during its internal `disable`. `SYSTEM_UNITS`
  only contains system units that really exist - pipewire/wireplumber (user
  scope) and swtpm (socket-activated) are **not** in it.
  PipeWire/WirePlumber/figma-agent come from their package presets and are
  **not** tracked (formerly `*.wants` links in the repo - now removed).
- **Not linked**: `AGENT/` (work/workflow files) stays in the repo root.
- Custom scripts: **`config/usrbin/*`** -> `~/.local/bin` (per file, on the
  `PATH` via `.bashrc`). `lib_hypr.sh` is a helper lib sourced via `source`
  (`workspace_slf`, `rofi_workspace_manager`). `dotfiles_sync` versions
  `setup/programs.txt`; `update_programs_list` writes there.
  `update_programs_list` is **additionally** linked to the fixed system path
  `/usr/local/bin/update_programs_list` (its own `links.conf` line), because the
  pacman hook (`/etc/pacman.d/hooks`) knows no `$HOME` variables and calls it from
  there - so the hook stays portable for a foreign user too.
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
  exclusively in `config/hypr/env.lua` (via `hl.env(...)`), **not** in `.bashrc`
  - do not duplicate them (otherwise apps render differently depending on how
  they were launched). (`hyprland.conf` is only the gitignored, auto-generated
  stub.)
- Hyprland config: since 0.55 **hyprlang (`.conf`) is deprecated** in favour of
  the **Lua config** (API global `hl`, loaded from `~/.config/hypr/hyprland.lua`,
  source under `config/hypr/`). `hyprland.lua` is only the **entry point** and
  loads the thematic modules via `require()` (`env`, `monitors`, `animations`,
  `devices`, `keybinds`, `looknfeel`, `autostart`) plus the central
  `programs.lua` (program names). Splitting pattern per the wiki
  (`require("module")`, flat in the hypr directory). On changes, maintain the
  matching module and check it with `luac -p <file>.lua`; format with **stylua**
  (tabs). `hyprland.conf` is **auto-generated** by Hyprland as a stub when Lua is
  used and is therefore **gitignored** - do not edit it. The old hyprlang config
  still lives in the git history or locally as `hyprland.conf.bak`. The conversion
  was done with `hyprlang2lua`.
- **KeePassXC DB** (`*.kdbx`) is excluded via `.gitignore` and the
  `config/keepassxc/` folder via `.claudeignore`.
- Commits are SSH-signed (`config/git/.gitconfig`).
- Two health/workflow skills write into `AGENT/`: `review-and-update-report`
  (health report) and `implement-todo` (work through `TODO.md`, one commit per
  item).
