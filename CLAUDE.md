# CLAUDE.md

Dotfiles for Arch Linux, deployed by `./install` (plain Bash, no dependencies).
Details on every config: `README.md`.

## Layout

- `config/<name>/` - config sources, flat.
- `setup/links.conf` - one line per link: `<source-in-repo> <target>`. A source
  ending in `/*` links each entry into a real target directory. `/etc` targets
  are always single files. A third field `optional` allows an empty glob.
- `setup/programs.txt`, `services.txt`, `groups.txt`, `fonts.txt` - data the
  installer reads. `programs.txt` is written by `config/usrbin/update_programs_list`
  (also run by the pacman hook).
- `AGENT/` is not linked. `AGENT/keymaps/keybinds.md` lists every keybinding;
  update it when a binding changes.
- `config/nvim/` has its own `CLAUDE.md`.

## Commands

```bash
./install                 # link everything, reactivate systemd units
./install --help          # all options and setup steps
./install status          # ok / foreign link / real file / missing per entry
./install validate        # read-only check of links.conf
./install --<step>        # run one setup step without linking
bash -n <script>          # or sh -n; shellcheck where available
```

A new setup step is one `register_step` call in `install`.

## Desktop

This machine runs KDE Plasma. The dwl setup is dormant, not deleted: its lines
in `links.conf` are commented out so it can come back. Keep `config/dwl`,
`config/usrbin`, `rofi`, `foot`, `wob`, `wbg`, `wallpaper` and `zen-yt` working
but do not re-enable them unless asked.

dwl specifics, for when it returns:

- `config/dwl/config.h` is compiled in, not linked. Apply with `./install --dwl`;
  takes effect in a new session. Patches in `config/dwl/patches/` are applied by `build-dwl`.
- No display manager: getty autologin on tty1, `~/.bash_profile` execs dwl.
- Autostart (`bat_check`, `clipboard_sanitize`, voxtype) is `autostart[]` in `config.h`.
- The screen locker is waylock, configured only by `lockcmd[]` in `config.h`.

## Pitfalls

- `config/locale/locale.conf` and `config/vconsole/` are copied, not linked
  (`--locale`, `--vconsole`): localed and early boot cannot read `/home`. Keep the
  Colemak DH layout in sync across `vconsole.conf`, `00-keyboard.conf`,
  `~/.config/kxkbrc` and voxtype's `eitype_xkb_*`.
- `mkinitcpio.conf` is not linked on this machine (hybrid NVIDIA/AMD, ext4); linking it can make the system unbootable.
- Units are activated with `systemctl enable`, never `reenable`: it deletes the unit symlink.
- `~/.mixxx/` stays real. Never track `mixxx.cfg` or `broadcast_profiles/*.bcp.xml`
  (plain-text streaming password; the repo is public).
- `config/mixxx/skins/` is a generator (`./install --mixxx-skin`), rerun after every
  mixxx update. Paths in the generated skin must be absolute; `build-skin` checks them.
- `sanitize` is the only script with format knowledge; clipboard images always go out as `image/png`.
- `yt_save` speaks native messaging on stdout; diagnostics go to stderr only.
  rofi `kb-custom-N` returns `9 + N`, `10` is `Shift+Return`.
- Do not reintroduce: the `~/outbox` watcher, auto-commits in the yt scripts,
  a `Shift+Return` action in `yt_menu`.
- `Ctrl+Shift+A` in foot: `PROMPT_RE` in `copy-visible` mirrors `PS1` in `.bashrc`.
- `*.kdbx` is gitignored, `config/keepassxc/` is in `.claudeignore`.
- New scripts start with `# SPDX-License-Identifier: ISC` and
  `# Copyright (C) <year> The leonhardweiler/dotfiles Authors`.
- Claude runs without permission prompts here on purpose (`.bashrc` alias,
  `skipDangerousModePermissionPrompt`, passwordless sudo). Keep it that way.
