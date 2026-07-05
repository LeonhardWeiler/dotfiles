# My Dotfiles

This repository contains my personal dotfiles for configuring my development environment. It includes settings for various tools and applications that I regularly use. The dotfiles are optimized for a minimal and fast workflow on Linux, specifically Arch Linux with the Hyprland window manager.

## Requirements

- **Linux-based operating system**
- **Git (`git`)** – for cloning the repository
- **Bash** – the `./install` script is plain Bash, no other dependencies
- **Sudo privileges** – for the system-wide (`/etc`) configuration

> Please back up your existing dotfiles before installing.

## Installation

Symlinks are managed by a small, dependency-free Bash script (`./install`). The
whole mapping lives in a single file, `links.conf` — one line per link, two
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
./install                 # = ./install link
```

**Recommended order on a fresh machine:** first install the packages
(`./scripts/install-programs.sh`), then run `./install` — otherwise the
`systemctl enable` calls (and the pacman hook / sync service) target units and
scripts that do not exist yet. Existing **real** default files (e.g. a shipped
`~/.bashrc`) are only *skipped*; re-run with `--force` to back them up to `.bak`
and replace them. `./install` prints a short "next steps" hint at the end
(`source ~/.bashrc`, re-login for the `.bash_profile` env). The scripts assume the
repo lives at `~/dotfiles`; if you clone elsewhere, export `DOTFILES_DIR` (used by
`dotfiles_sync`/`update_programs_list`) accordingly.

Useful variants:

```bash
./install status          # show state of every entry (ok / foreign link / real file / missing)
./install --user-only     # only ~ targets, never touch /etc, no sudo
./install -n              # dry run: print what would happen, change nothing
./install --force         # back up real files/dirs at the target to .bak, then link
./install clean           # delete the .bak backups that --force created
./install unlink          # remove the symlinks this repo manages
```

> **Repo layout:** every config lives directly under `config/<name>/` (flat
> source paths — e.g. `config/btop/btop.conf`), and `links.conf` maps each source
> to its target. Existing symlinks are always replaced; by default `./install`
> never overwrites a **real** file/dir (only symlinks are replaced) — use
> `--force` to back those up to `.bak` and replace them. `unlink` only removes
> symlinks that point back into this repo. If a source path ends in `/*`, each
> entry inside it is linked individually into the target directory, which stays
> real — used for `config/usrbin/*` → `~/.local/bin`, so foreign entries there
> (e.g. `claude`) are left untouched.
> `scripts/` holds the remaining repo tooling (`install-programs.sh`,
> `update-package-list.sh`, `programs.txt`).

After installation, restart your shell or `source ~/.bashrc` to apply the Bash
configuration.

## Systemd Services

### System Services

The system services below are enabled automatically by `./install` (the
`SYSTEM_UNITS` list at the top of the script, via `systemctl enable` — without
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

### User Services

`./install` reactivates the user units (the `USER_UNITS` list in the script:
`systemctl --user enable battery-check.timer dotfiles-sync.service`).
PipeWire/WirePlumber/figma-agent are enabled by their own package presets and are
**not** managed here. To do it by hand:

```bash
systemctl --user enable --now battery-check.timer
# Sync von `programs.txt` (und weiteren Configs) bei jedem Login: commit + push
systemctl --user enable --now dotfiles-sync.service
```

> `dotfiles-sync.service` committet und **pusht** automatisch. Das setzt einen
> ohne Interaktion nutzbaren SSH-Key voraus (passphrase-los oder per `ssh-agent`
> beim Login bereitgestellt); sonst schlägt nur der Push fehl (best effort, der
> Login wird nicht blockiert). Erweiterbar über `GENERATORS`/`PATHS` in
> `~/.local/bin/dotfiles_sync`.

Check status:

```bash
systemctl --user status <name>.service
```

## Contents

| Component      | Path                               |
| -------------- | ---------------------------------- |
| Alacritty      | `~/.config/alacritty`              |
| Bash           | `~/.bashrc`                        |
| btop           | `~/.config/btop`                   |
| Claude Code    | `~/.claude/{skills,settings.json}` |
| Git            | `~/.config/git`                    |
| Hyprland       | `~/.config/hypr`                   |
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
| Systemd User   | `~/.config/systemd/`               |
| Systemd System | `/etc/systemd/system/`             |
| Typst          | `~/.config/typst`                  |

## My Setup

I use Arch Linux with the Hyprland window manager. The file `programs.txt` contains a complete list of installed packages. A pacman hook (`/etc/pacman.d/hooks`, installed via the `pacman` package) regenerates it automatically after every `pacman`/`yay` transaction, and `dotfiles-sync.service` commits and pushes it on login. You can still refresh it manually while installing via the install script.

> Note: This setup has been primarily tested on Arch Linux. Other distributions may require adjustments.

## Manual system state (not symlinked)

Some system state is not a config file this repo can symlink — it has to be set
up by hand on a fresh machine (the kind of thing a declarative distro like NixOS
would capture). Checklist:

- **User groups** — add your user to the groups the tracked tools need:

  ```bash
  sudo usermod -aG wheel,input,kvm,libvirt,uucp,disk,lock <user>
  # add docker / wireshark only if you actually install those packages
  ```

  Group changes take effect after re-login. Conversely, drop groups whose program
  you no longer have installed, e.g. `sudo gpasswd -d <user> docker`.
- **Timezone**: `sudo ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime`
- **Locales**: `/etc/locale.conf` and `/etc/locale.gen` are tracked, but the
  locales still have to be generated once: `sudo locale-gen`.
- **Bootloader / kernel cmdline**: systemd-boot (ESP at `/efi`); the kernel
  options `amd_pstate=active usbcore.autosuspend=1 quiet` live in
  `/efi/loader/entries/arch.conf` (`options` line) — machine-specific
  (`root=UUID=…`), so set them by hand rather than tracking the file.
- **Not tracked on purpose** (machine-specific / secrets): `/etc/hostname`,
  `/etc/fstab` (UUIDs), and NetworkManager Wi-Fi profiles
  (`/etc/NetworkManager/system-connections/*.nmconnection`, contain PSKs).
- **sudo**: this setup relies on passwordless sudo for the `wheel` group
  (`%wheel ALL=(ALL:ALL) NOPASSWD: ALL` in `/etc/sudoers`) — a deliberate
  convenience choice; adjust to taste.

## Notes

- Some applications may require additional dependencies not covered by this repository.
- Adjust paths and configurations to your personal environment.
- Backing up existing configurations is strongly recommended.
- To update the program list without relinking, run `./scripts/update-package-list.sh`.
- To install all packages from `programs.txt`, run `./scripts/install-programs.sh`

### New Initramfs

`mkinitcpio.conf` is tracked and linked to `/etc/mkinitcpio.conf` via `links.conf`
(source `config/mkinitcpio/mkinitcpio.conf`). After modifying it, regenerate the
initramfs with:

```bash
sudo mkinitcpio -P
```

## License

GPL-3.0 License
