# My Dotfiles

This repository contains my personal dotfiles for configuring my development environment. It includes settings for various tools and applications that I regularly use. The dotfiles are optimized for a minimal and fast workflow on Linux, specifically Arch Linux with the Hyprland window manager.

## Requirements

* **Linux-based operating system**
* **Bash shell (`bash`)** – required for installation and shell configuration
* **Git (`git`)** – for cloning the repository
* **GNU Stow (`stow`)** – for managing symlinks
* **Sudo privileges** – for system-wide configuration

> Please back up your existing dotfiles before running the installation script.

## Installation

Clone the repository:

```bash
git clone https://github.com/leonhardweiler/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Make the installation script executable and run it:

```bash
chmod +x install.sh
# sudo is required to write to system directories
sudo ./install.sh
```

After installation, restart your shell or run the following to apply the Bash configuration:

```bash
source ~/.bashrc
```

The script will overwrite the `programs.txt` file with your current package list.

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
systemctl --user enable --now battery-check.service
```

Check status:

```bash
systemctl --user status <name>.service
```

## Contents

| Component      | Path                   |
| -------------- | ---------------------- |
| Alacritty      | `~/.config/alacritty`  |
| Bash           | `~/.bashrc`            |
| Git            | `~/.config/git`        |
| Hyprland       | `~/.config/hypr`       |
| KeePassXC      | `~/.config/keepassxc`  |
| Ly             | `/etc/ly`              |
| Mako           | `~/.config/mako`       |
| MPV            | `~/.config/mpv`        |
| Neovim         | `~/.config/nvim`       |
| Passwords      | `~/.config/passwords`  |
| Rofi           | `~/.config/rofi`       |
| Scripts        | `~/.config/scripts`    |
| Systemd User   | `~/.config/systemd/`   |
| Systemd System | `/etc/systemd/system/` |
| Typst          | `~/.config/typst`      |
| Zram           | `/etc/systemd/system/` |

## My Setup

I use Arch Linux with the Hyprland window manager. The file `programs.txt` contains a complete list of installed packages and is updated when the installation script is run.

> Note: This setup has been primarily tested on Arch Linux. Other distributions may require adjustments.

## Notes

* Some applications may require additional dependencies not covered by this repository.
* Adjust paths and configurations to your personal environment.
* Backing up existing configurations is strongly recommended.

## License

GPL-2.0 License
