# My Dotfiles

This repository contains my personal dotfiles for configuring my development environment. It includes settings for various tools and applications that I regularly use. The dotfiles are optimized for a minimal and fast workflow on Linux, specifically Arch Linux with the Hyprland window manager.

## Requirements

- **Linux-based operating system**
- **Bash shell (`bash`)** – required for installation and shell configuration
- **Git (`git`)** – for cloning the repository
- **GNU Stow (`stow`)** – for managing symlinks
- **Sudo privileges** – for system-wide configuration

> Please back up your existing dotfiles before running the installation script.

## Installation

Clone the repository:

```bash
git clone https://github.com/leonhardweiler/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Make the installation script executable and run it:

```bash
chmod +x scripts/install.sh
# Run as your normal user — the script requests sudo itself for system packages
./scripts/install.sh
```

> **Repo layout:** all Stow packages live under `config/` (Stow is invoked with
> `--dir=config`), while `scripts/` holds the repository tooling
> (`install.sh`, `install-programs.sh`, `update-package-list.sh`,
> `programs.txt`). The former `scripts` package that links executables into
> `~/.local/bin` is now `config/usrbin`. On first run after this layout change,
> `install.sh` removes orphaned symlinks that still point at the old paths
> before re-linking (systemd enablement links under `*.wants`/`*.requires` are
> left untouched).

After installation, restart your shell or run the following to apply the Bash configuration:

```bash
source ~/.bashrc
```

After applying the changes, the script asks whether to refresh `programs.txt`
from your currently installed packages. This prompt defaults to **yes** (just
press Enter); answer `n` to keep the existing list.

All symlinks will be created in the directories defined in the repository.

## Systemd Services

### System Services

The following system services should be enabled:

```bash
sudo systemctl enable --now zram.service
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now ly@tty2.service
sudo systemctl enable --now pipewire.service
sudo systemctl enable --now wireplumber.service
sudo systemctl enable --now dnsmasq.service
sudo systemctl enable --now sshd.service
sudo systemctl enable --now swtpm.service
sudo systemctl enable --now libvirtd.service
sudo systemctl enable --now legion-conservation.service
```

Check status:

```bash
sudo systemctl status <name>.service
```

### User Services

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

| Component      | Path                      |
| -------------- | ------------------------- |
| Alacritty      | `~/.config/alacritty`     |
| Bash           | `~/.bashrc`               |
| btop           | `~/.config/btop`          |
| Git            | `~/.config/git`           |
| Hyprland       | `~/.config/hypr`          |
| KeePassXC      | `~/.config/keepassxc`     |
| Ly             | `/etc/ly`                 |
| Mako           | `~/.config/mako`          |
| MIME defaults  | `~/.config/mimeapps.list` |
| MPV            | `~/.config/mpv`           |
| Neovim         | `~/.config/nvim`          |
| Pacman hooks   | `/etc/pacman.d/hooks`     |
| PipeWire       | `~/.config/pipewire`      |
| qt5ct          | `~/.config/qt5ct`         |
| Rofi           | `~/.config/rofi`          |
| Scripts        | `~/.local/bin`            |
| Systemd User   | `~/.config/systemd/`      |
| Systemd System | `/etc/systemd/system/`    |
| Typst          | `~/.config/typst`         |

## My Setup

I use Arch Linux with the Hyprland window manager. The file `programs.txt` contains a complete list of installed packages. A pacman hook (`/etc/pacman.d/hooks`, installed via the `pacman` package) regenerates it automatically after every `pacman`/`yay` transaction, and `dotfiles-sync.service` commits and pushes it on login. You can still refresh it manually while installing via the install script.

> Note: This setup has been primarily tested on Arch Linux. Other distributions may require adjustments.

## Notes

- Some applications may require additional dependencies not covered by this repository.
- Adjust paths and configurations to your personal environment.
- Backing up existing configurations is strongly recommended.
- To update the program list without relinking, run `./scripts/update-package-list.sh`.
- To install all packages from `programs.txt`, run `./scripts/install-programs.sh`

### New Initramfs

After modifying the `mkinitcpio.conf`, regenerate the initramfs with:

```bash
sudo mkinitcpio -P
```

## License

GPL-3.0 License
