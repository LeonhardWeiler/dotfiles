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
  `systemd-system`, `usrbin`, `wallpaper`, `wbg`, `wob`, `zen-yt`.
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
  (a `while` loop calling `bat_check` every 2 min), and the clipboard metadata
  watcher (`clipboard_sanitize`) starts the same way.
  Deliberately `enable`, **not**
  `reenable`: our unit files are symlinks (linked units), and `reenable` would
  delete exactly that unit symlink during its internal `disable`. `SYSTEM_UNITS`
  only contains system units that really exist - pipewire/wireplumber run in the
  user scope and are **not** in it.
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
- **Booting** is **EFISTUB**, not a bootloader: the custom kernel is built with
  `CONFIG_EFI_STUB=y` and boots **without an initramfs**, so the firmware starts
  `vmlinuz` on the ESP directly. `config/usrbin/efistub-entry <kernel-on-esp>
  [<cmdline>]` writes the EFI NVRAM entry (needs root; without `<cmdline>` it
  reuses `/proc/cmdline`) - idempotent, it deletes an existing entry of the same
  label first. systemd-boot deliberately **stays** at the ESP fallback path
  (`/efi/EFI/BOOT/BOOTX64.EFI`) as the safety net, since the firmware here keeps
  no OS-created NVRAM entry of its own. A new kernel revision therefore needs one
  `efistub-entry` run (README section "EFISTUB").
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
  tags**, and `AGENT/keymaps/keybinds.md` lists every binding on the system (snapshot -
  `config.h` stays the authority). `build-dwl` only contacts the remote when the
  pinned tag is missing locally, so an outage cannot block applying a `config.h`
  change.
- **`Ctrl+Shift+Y` (copy last command + output)** spans three files that must
  stay in sync: `config/bash/foot-shell-integration.bash` (sourced from
  `.bashrc`, own `links.conf` line to `~/.config/bash/`) emits the **OSC-133**
  markers (`A`/`C`/`D`) and stashes the command line in
  `$XDG_RUNTIME_DIR/foot-last-command.<foot-pid>` from a `DEBUG` trap - it
  overrides `PROMPT_COMMAND`, so it must be sourced *after* the prompt setup;
  `config/foot/foot.ini` binds `pipe-command-output` to
  `config/usrbin/copy-last-command`, which reads the output on stdin, the
  command from that file, and pipes `Input:`/`Output:` into `wl-copy`. Both
  sides find each other by walking up to the owning **foot** process, so this
  breaks under `foot --server`/`footclient` (one process for all windows).
  Removing the OSC-133 markers would also kill foot's prompt jumping.
  **`Ctrl+Shift+A`** is the same idea for the whole screen (everything since the
  last `clear`): `pipe-visible` -> `config/usrbin/copy-visible`. foot pipes that
  as plain text with no markers left in it, so the script splits the blocks by
  matching **prompt lines** with a regex that mirrors `PS1` - editing `PS1` in
  `.bashrc` means editing `PROMPT_RE` in `copy-visible`.
- **App launcher**: `MOD+I` runs `config/usrbin/app_menu`, **not** `rofi -show
  drun`. Reason: rofi's `-no-custom` (Return is a no-op while nothing matches,
  which is what `mount_menu`/`sanitize_menu` rely on) is implemented in the
  **dmenu mode only**, so drun answers a typo with a `Failed to execute:`
  dialog. The script therefore does drun's job itself: scan the `.desktop`
  files of the XDG data dirs (user dir first, one entry per desktop-id),
  filter `NoDisplay`/`Hidden`/`TryExec`/`OnlyShowIn`/`NotShowIn`, and launch
  the `Exec` line with the field codes stripped (`Path=` as cwd,
  `Terminal=true` and `Shift+Return` through `$TERMINAL`, default foot).
  Ranking is a counter file in **drun's own format**
  (`~/.cache/app_menu.history`, `<count> <desktop-id>`), seeded once from
  `~/.cache/rofi3.druncache` - do not change that format without a migration.
- **Removable drives**: `config/usrbin/mount_menu` (rofi, bound to `MOD+M` in
  `config/dwl/config.h`) mounts/unmounts/ejects them with plain
  `mount`/`umount` via `sudo -n` (the passwordless `wheel` rule from
  `--sudoers`) - **no udisks2/polkit**, mount points under
  `/run/media/<user>/<label>`. `sudo -n` everywhere so a missing rule errors
  instead of hanging on a password prompt with no terminal. Encrypted volumes
  are deliberately unsupported: the custom kernel has **no device-mapper**
  (`dm_mod` is missing), so dm-crypt/LVM cannot work on this machine anyway.
- **Metadata stripping** spans three scripts in `config/usrbin/`, all built on
  **`sanitize`** (the only one with format knowledge: `exiftool -all=` for
  images - lossless, `ffmpeg -c copy -map_metadata -1` for a/v, `mat2` for
  everything else; an unsupported format is a hard error, never a silent pass).
  It also renames (`image-<hex8>.jpg`) and re-stamps the mtime, since file name
  and `lastModified` leak as loudly as EXIF; copies go to
  `$XDG_RUNTIME_DIR/sanitized`. The two front-ends: **`sanitize_menu`** (rofi,
  `MOD+S` in `config/dwl/config.h`; `Return` = image on the clipboard,
  `Shift+Return` = path, because `wl-copy` offers one MIME type per call) and
  **`clipboard_sanitize`** (one `wl-paste --watch` per MIME type in `TYPES` -
  png/jpeg/webp/tiff/gif/avif -, loop-safe via a sha256 of what it wrote).
  `sanitize_menu` is a **single** rofi window that filters live: the candidates
  are piped in once and rofi does the matching, which only stays instant while
  the list stays small - hence `EXTENSIONS`, which keeps the metadata-carrying
  formats (~19k of 278k files here) and drops what `sanitize` would reject on
  `Return` anyway. It deliberately passes **no `-p`**, so only the theme's
  `Search...` placeholder shows, like `MOD+I`. The candidate list is built by
  **`rg --files`** (threaded walk + extension globs, so only survivors are
  `stat`ed) and sorted under **`LC_ALL=C`** - UTF-8 collation alone cost 170 ms
  of the former ~350 ms, so keep that prefix on `sort`/`sed` and keep it *off*
  the script as a whole (rofi and the file names need the real locale). The watcher runs from the dwl `autostart[]`, not
  as a systemd user unit - same reasoning as `bat_check`. Both front-ends locate
  `sanitize` via `dirname "$0"`, not `PATH`. A **watched `~/outbox` directory**
  was built and then dropped on purpose - do not reintroduce it without asking.
- **The YouTube lists** span a browser add-on and two scripts, and the notes
  repo they write to (`~/files/repos/notes/yt/`) is **not** part of this repo.
  `config/zen-yt/` is the add-on (`manifest.json`, `content.js` for the hover
  state, `background.js` for the two `commands`) plus `build-xpi`; it is **not**
  symlinked - only `at.leo.yt_save.json` is, into
  `~/.mozilla/native-messaging-hosts` (Firefox-based browsers hardcode
  `~/.mozilla` regardless of the app name - verified in Zen's `libxul.so`, and
  the reason KeePassXC's manifest sits there too). That manifest needs an
  **absolute** `path`, so `/home/leo` is spelled out in it, same as the
  `signingkey` in `config/git/config`. The two ends: `config/usrbin/yt_save` is
  the native messaging host (4-byte length prefix, then JSON, on stdin *and*
  stdout - **stdout belongs to the protocol**, every diagnostic goes to stderr),
  `config/usrbin/yt_menu` is the rofi front-end on `MOD+Y`. `content.js` must
  **not** take a hovered link's own text as the title - on a thumbnail that is
  the duration badge plus its screen-reader text; it resolves the title from
  the `title` attribute, then from another anchor with the same video id or the
  enclosing card (`ytd-*-renderer` / `yt-lockup-view-model`), and treats
  anything starting with `\d+:\d+` as not-a-title. A length glued to the *end*
  of the title ("… 28 minutes", the a11y spelling of the badge) is cut off,
  guarded three ways - the words must be time words (en/de list), the numbers
  must be the card badge's, and the preceding word must not be `in`/`unter`/… -
  so "… in 11 Minutes" and "Die 3 Musketiere" survive. Both commit into the
  notes repo with `git commit -- <path>`, which leaves anything else staged
  there alone. An unsigned add-on only installs because Zen is built with
  `MOZ_REQUIRE_SIGNING=false`; a Zen build that changes that would take the
  feature with it. **rofi exit codes**: `10` is `Shift+Return` (alternate
  accept, the same assumption `sanitize_menu` runs on), and `kb-custom-N`
  returns `9 + N` - so `kb-custom-1` would collide with it. `yt_menu` therefore
  binds `Alt+BackSpace` to `kb-custom-2` and reads `11`, which was measured
  against the installed rofi rather than taken from the manpage. It has **no**
  `Shift+Return` action (removed on purpose, not to be reintroduced) and loops:
  a removal rebuilds the index and reopens rofi with `-filter` set to what was
  typed (`-format 'i f'` returns row number *and* filter), dropping the filter
  when it no longer matches a row.
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
  item). `AGENT/keymaps/keybinds.md` is a hand-kept overview of every keybinding on the
  system - update it when a binding changes.
- **Claude Code runs without permission prompts here, on purpose**: `.bashrc`
  aliases `claude` to `claude --dangerously-skip-permissions` and
  `config/claude/settings.json` sets `skipDangerousModePermissionPrompt`.
  Together with the passwordless `wheel` sudo from `--sudoers` that means no
  guard rails at all - documented in the README, and the alias is meant to stay
  the command.
