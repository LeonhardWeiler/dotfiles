# My Dotfiles

![desktop screenshot](./images/hyprland-screenshot.png)

This repository contains my personal dotfiles for configuring my development environment. It includes settings for various tools and applications that I regularly use. The setup targets a fast, keyboard-driven workflow on GNU/Linux, specifically Arch GNU/Linux with the dwl Wayland compositor. It is meant to be _practical_, not minimalist: the lean, dependency-free tooling (the `./install` script, small POSIX-`sh` helpers) sits next to heavyweight applications I need for work (game engine, .NET, VMs) - see [Non-free packages](#non-free-packages) for what that pulls in.

## Requirements

- **GNU/Linux-based operating system**
- **Git (`git`)** - for cloning the repository
- **Bash** - the `./install` script is plain Bash, no other dependencies
- **Sudo privileges** - for the system-wide (`/etc`) configuration

> Please back up your existing dotfiles before installing.

## Installation

Symlinks are managed by a small, dependency-free Bash script (`./install`). The
whole mapping lives in a single file, `setup/links.conf` - one line per link, two
columns: `<source-in-repo>  <target>`. Targets under `~` are user configs;
`/etc/…` targets are system configs and are linked via `sudo`.

Clone the repository:

```bash
git clone https://github.com/leonhardweiler/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Create all symlinks from `links.conf` (user and, via `sudo`, `/etc` targets) and
(re)activate the systemd units:

```bash
./install                 # = ./install link  (everyday: refresh symlinks + units)
```

**Fresh machine - one command:** `./install setup` runs the whole bootstrap. On
a terminal it shows a **menu of optional steps** (Enter picks the defaults); it
then links every config (implies `--force`, backing up real files to `.bak`) and
runs the selected steps:

```bash
./install setup
```

The optional steps (menu entries; each also has a flag, see below):

| Step                                                | Flag              | Default |
| --------------------------------------------------- | ----------------- | ------- |
| Install packages from `programs.txt`                | `--programs`      | ✓       |
| (Re)activate systemd units                          | `--systemd`       | ✓       |
| Add user to the required groups (`usermod -aG`)     | `--groups`        |         |
| Set the timezone (`/etc/localtime`)                 | `--timezone ZONE` |         |
| Generate locales (`locale-gen`)                     | `--locale`        | ✓       |
| Deploy the ly@tty2 drop-ins as real copies          | `--ly-dropin`     |         |
| Passwordless sudo for `wheel` (`/etc/sudoers.d/`)   | `--sudoers`       |         |
| Rebuild the initramfs (`mkinitcpio -P`)             | `--initramfs`     |         |
| Install fonts + refresh the font cache (`fc-cache`) | `--fonts`         |         |

Each step is also runnable on its own for automation: `./install --<step>` runs
just those steps (no linking, no menu), e.g. `./install --timezone Europe/Vienna`
or `./install --groups --sudoers`. To skip the menu but still do the full setup,
pass the flags to `setup`: `./install setup --programs --systemd --locale`.

The scripts assume the repo lives at `~/dotfiles`; if you clone elsewhere, export
`DOTFILES_DIR` (used by `dotfiles_sync`/`update_programs_list`) accordingly.

Useful variants:

```bash
./install status          # show state of every entry (ok / foreign link / real file / missing)
./install validate        # check links.conf (strict, read-only) - no filesystem changes
./install --user-only     # only ~ targets, never touch /etc, no sudo
./install -n              # dry run: print what would happen, change nothing
./install --force         # back up real files/dirs at the target to .bak, then link
./install unlink          # remove the symlinks this repo manages
```

> Every command validates `links.conf` first and **aborts on any problem**
> (nothing changed), reporting `links.conf:<line>: <msg>`. It rejects: a missing
> target, stray extra fields, an absolute source, a non-existent source, a
> duplicate target, a target outside `~` / `/etc` / `/usr/local`, and a glob that
> matches nothing. A glob that may legitimately be
> empty can be marked with a third `optional` field
> (`config/foo/* ~/dir optional`). Run `./install validate` on its own to check
> without linking.

> Everyday use is just `./install` (idempotent, never overwrites real files).
> `setup` is the one-shot fresh-machine bootstrap; to only (re)install packages
> without touching anything else, run `./setup/install-programs` directly.

> **Repo layout:** every config lives directly under `config/<name>/` (flat
> source paths - e.g. `config/btop/btop.conf`), and `setup/links.conf` maps each
> source to its target. Existing symlinks are always replaced; by default
> `./install` never overwrites a **real** file/dir (only symlinks are replaced) -
> use `--force` to back those up to `.bak` and replace them. `unlink` only removes
> symlinks that point back into this repo. If a source path ends in `/*`, each
> entry inside it is linked individually into the target directory, which stays
> real - used for `config/usrbin/*` -> `~/.local/bin`, so foreign entries there
> (e.g. `claude`) are left untouched.
> `setup/` holds the deployment machinery: the link map (`links.conf`), the
> package manifest (`programs.txt`), the `install-programs` bootstrap script, and
> the data lists the installer reads instead of hardcoding them - `services.txt`
> (systemd units), `groups.txt` and `fonts.txt`. The package list itself is
> regenerated by `update_programs_list` (`config/usrbin/`, on `PATH`), which the
> pacman hook also calls.

After installation, restart your shell or `source ~/.bashrc` to apply the Bash
configuration.

## Systemd Services

### System Services

The system services below are enabled automatically by `./install` (the
`system` entries in `setup/services.txt`, via `systemctl enable` - without
`--now`, so the running session is not disturbed; start them manually or reboot
to activate). To do it by hand:

```bash
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now ly@tty2.service
sudo systemctl enable --now dnsmasq.service
sudo systemctl enable --now sshd.service
sudo systemctl enable --now libvirtd.service
sudo systemctl enable --now legion-conservation.service
sudo systemctl enable --now iptables.service
sudo systemctl enable --now power-profiles-daemon.service
sudo systemctl enable --now systemd-timesyncd.service
sudo systemctl enable --now fstrim.timer
```

> Note: `swtpm` (socket-activated) and PipeWire/WirePlumber (user-scope, enabled
> per-user by package presets) have no enable-able system `*.service` and are
> therefore **not** in the list.

Check status:

```bash
sudo systemctl status <name>.service
```

### Login-time helpers (no user units)

There are **no systemd user units**. Two things that would otherwise want a
`.timer`/`.service` run as plain commands from the dwl autostart
(`autostart[]` in `config/dwl/config.h`), so nothing needs to be enabled:

- **Battery warning** - a shell loop calls `bat_check` every 2 minutes:
  `while true; do ~/.local/bin/bat_check; sleep 120; done`.
- **Config sync** - `dotfiles_sync` runs once on login to commit + push
  `programs.txt` (and further tracked configs).

> `dotfiles_sync` commits and **pushes** automatically. That requires an SSH key
> usable without interaction (passphrase-less or provided via `ssh-agent` at
> login); otherwise only the push fails (best effort, login is not blocked).
> Extensible via `GENERATORS`/`PATHS` in `~/.local/bin/dotfiles_sync`.

PipeWire/WirePlumber/figma-agent are enabled by their own package presets and are
**not** managed here.

## Contents

| Component      | Path                               |
| -------------- | ---------------------------------- |
| Bash           | `~/.bashrc`                        |
| btop           | `~/.config/btop`                   |
| Claude Code    | `~/.claude/{skills,settings.json}` |
| dwl            | compiled + `/usr/local` session    |
| foot           | `~/.config/foot`                   |
| Git            | `~/.config/git`                    |
| hyprlock       | `~/.config/hypr/hyprlock.conf`     |
| KeePassXC      | `~/.config/keepassxc`              |
| Ly             | `/etc/ly`                          |
| Mako           | `~/.config/mako`                   |
| MIME defaults  | `~/.config/mimeapps.list`          |
| mkinitcpio     | `/etc/mkinitcpio.conf`             |
| MPV            | `~/.config/mpv`                    |
| Neovim         | `~/.config/nvim`                   |
| Pacman hooks   | `/etc/pacman.d/hooks`              |
| PipeWire       | `~/.config/pipewire`               |
| qt5ct          | `~/.config/qt5ct`                  |
| Rofi           | `~/.config/rofi`                   |
| Scripts        | `~/.local/bin`                     |
| Systemd System | `/etc/systemd/system/`             |
| Wallpapers     | `~/.local/share/wallpapers`        |

## My Setup

I use Arch GNU/Linux with the dwl Wayland compositor. The file `programs.txt` contains a complete list of installed packages. A pacman hook (`/etc/pacman.d/hooks`, installed via the `pacman` package) regenerates it automatically after every `pacman`/`yay` transaction, and `dotfiles_sync` (run from the dwl autostart) commits and pushes it on login. You can still refresh it manually while installing via the install script.

> Note: This setup has been primarily tested on Arch GNU/Linux. Other distributions may require adjustments.

## Non-free packages

In the interest of honesty: `programs.txt` is not a free-software-only manifest. Some tracked packages are **proprietary** and installed from the AUR:

- **`unityhub`** (and the Unity editor it manages) - proprietary game engine.
- **`plasticscm-client-gui`** - proprietary version control (Unity/PlasticSCM).
- **`figma-agent-linux-bin`** - proprietary font helper for Figma.

In addition, **`linux-firmware`** and **`amd-ucode`** ship non-free binary blobs (device firmware / CPU microcode) that the stock `linux` kernel loads. If you want a fully free system, drop the packages above and swap `linux`/`linux-firmware` for `linux-libre`/`linux-libre-firmware` (note: some hardware then loses driver support). The rest of the tooling (dwl, foot, Neovim, mpv, KeePassXC, …) is free software.

## Manual system state (not symlinked)

Some system state is not a config file this repo can symlink. Most of it is now
available as optional `./install setup` steps (see the table above), but the
commands are kept here as reference and for doing them by hand. Checklist:

- **User groups** (`./install --groups`) - add your user to the groups the
  tracked tools need:

  ```bash
  sudo usermod -aG wheel,input,kvm,libvirt,uucp,disk,lock <user>
  ```

  Group changes take effect after re-login. Conversely, drop groups whose program
  you no longer have installed, e.g. `sudo gpasswd -d <user> docker`.

- **Timezone** (`./install --timezone Europe/Vienna`):
  `sudo ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime`
- **Locales** (`./install --locale`): `/etc/locale.conf` and `/etc/locale.gen`
  are tracked, but the locales still have to be generated once: `sudo locale-gen`.
- **Bootloader / kernel cmdline**: systemd-boot (ESP at `/efi`); the kernel
  options `amd_pstate=active usbcore.autosuspend=1 quiet` live in
  `/efi/loader/entries/arch.conf` (`options` line) - machine-specific
  (`root=UUID=…`), so set them by hand rather than tracking the file.
- **Not tracked on purpose** (machine-specific / secrets): `/etc/hostname`,
  `/etc/fstab` (UUIDs), and NetworkManager Wi-Fi profiles
  (`/etc/NetworkManager/system-connections/*.nmconnection`, contain PSKs).
- **ly@tty2 drop-ins** (`./install --ly-dropin`;
  `/etc/systemd/system/ly@tty2.service.d/`): the files in
  `config/systemd-system/ly@tty2.service.d/` (`wait-home.conf`, `keymap.conf`)
  must be deployed as **real copies on the root partition**, not symlinked via
  `links.conf` - systemd reads unit drop-ins early at manager start, when a
  `/home` symlink would still be a dead link. Deploy by hand:

  ```bash
  sudo install -d -m755 /etc/systemd/system/ly@tty2.service.d
  sudo install -m644 config/systemd-system/ly@tty2.service.d/*.conf \
      /etc/systemd/system/ly@tty2.service.d/
  sudo systemctl daemon-reload
  ```

  `wait-home.conf` waits for the `/home` mount (the `/etc/ly/config.ini` symlink
  lives there); `keymap.conf` reloads the console keymap right before `ly-dm`
  (`ExecStartPre=loadkeys …`) to work around a boot-time KMS/vconsole-setup race
  that otherwise leaves the ly login field on QWERTY instead of the
  `/etc/vconsole.conf` `KEYMAP`.

- **sudo** (`./install --sudoers`): this setup relies on passwordless sudo for
  the `wheel` group (`%wheel ALL=(ALL:ALL) NOPASSWD: ALL`, written to
  `/etc/sudoers.d/10-wheel-nopasswd` and validated with `visudo -c`) - a
  deliberate convenience choice; adjust to taste.

## Notes

- Some applications may require additional dependencies not covered by this repository.
- Adjust paths and configurations to your personal environment.
- Backing up existing configurations is strongly recommended.
- To update the program list without relinking, run `update_programs_list` (on
  `PATH` via `~/.local/bin`; the same script the pacman hook uses).
- To install all packages from `programs.txt`, run `./setup/install-programs`

### New Initramfs

`mkinitcpio.conf` is tracked and linked to `/etc/mkinitcpio.conf` via `links.conf`
(source `config/mkinitcpio/mkinitcpio.conf`). After modifying it, regenerate the
initramfs with `./install --initramfs`, or by hand:

```bash
sudo mkinitcpio -P
```

## License

Licensed under the ISC License - SPDX identifier
[`ISC`](https://spdx.org/licenses/ISC.html). The full license text is in
[`LICENSE`](LICENSE). Bundled third-party files (e.g. under `config/mpv/`) keep
their own license.
