# My dotfiles
This repository contains my personal dotfiles for configuring my development environment. It includes configurations for various tools and applications that I use regularly.

## Installation
Clone Git repository:
```bash
git clone https://github.com/leonhardweiler/dotfiles.git ~/dotfiles
```

Make script executable and run it:
```bash
chmod +x ~/dotfiles/install.sh
sudo ~/dotfiles/install.sh
```
You have to use `sudo` to create the symlink for the `ly` display manager
configuration.

All the symlinks will be created in the locations listed below.

## Contents
- alacritty (`~/.config/alacritty`)
- bash (`~/.bashrc`)
- git (`~/.config/git`)
- hypr (`~/.config/hypr`)
- keepassxc (`~/.config/keepassxc`)
- ly (`/etc/ly`)
- mako (`~/.config/mako`)
- mpv (`~/.config/mpv`)
- nvim (`~/.config/nvim`)
- passwords (`~/.config/passwords`)
- rofi (`~/.config/rofi`)
- scripts (`~/.config/scripts`)
- systemd (`~/.config/systemd/`)
- typst (`~/.config/typst`)
