# CLAUDE.md

Hinweise für die Arbeit an diesem Dotfiles-Repo. Kommentar-/Doku-Sprache: **Deutsch**.

## Überblick

Persönliche Dotfiles für Arch Linux mit Hyprland (Wayland), verwaltet über
**GNU Stow**. Der Repo-Root trennt **`config/`** (alle Stow-Pakete) von
**`scripts/`** (Repo-Werkzeuge, keine Stow-Pakete). Jedes Verzeichnis unter
`config/` ist ein Stow-Paket, dessen innere Struktur das Zielverzeichnis
spiegelt — meist `$HOME` (z. B. `config/alacritty/.config/alacritty/…` →
`~/.config/alacritty/…`), bei Root-Paketen `/` (z. B. `config/ly/etc/ly/…` →
`/etc/ly/…`). Stow wird mit `--dir=config` aufgerufen. Details zu Inhalten/
Pfaden: `README.md`.

## Installation & Befehle

- **Verlinken**: `./scripts/install.sh` — fragt vor dem Anwenden, führt
  `stow --dir=config -R` je Paket aus. User-Pakete relativ zu `$HOME`,
  Root-Pakete (`ROOT_PKGS`) via `sudo stow --dir=config --target=/`. Vor dem
  Neu-Verlinken werden **verwaiste Symlinks** aus einem früheren Layout entfernt
  (nur kaputte Links, die ins Repo zeigen; systemd-Enablement-Links unter
  `*.wants`/`*.requires` bleiben verschont). Danach optional `programs.txt`
  aktualisieren.
- **Paketliste aktualisieren** (ohne Neu-Verlinken): `./scripts/update-package-list.sh`.
- **Pakete aus `programs.txt` installieren**: `./scripts/install-programs.sh` (nutzt `yay`).
- **Shell-Skripte prüfen** (kein Test-Framework): `bash -n <skript>`; wo vorhanden
  `shellcheck <skript>`.

## Struktur

- **`config/`** = alle Stow-Pakete. Konfig-Pakete: `alacritty`, `bash`, `btop`,
  `claude`, `git`, `hypr`, `keepassxc`, `mako`, `mimeapps`, `mpv`, `pipewire`,
  `qt5ct`, `rofi`, `usrbin`, `typst`, `systemd-user`. Bei `btop`/`qt5ct`/
  `pipewire`/`mimeapps`/`claude` wird bewusst nur die jeweilige Config-Datei
  (bzw. bei `claude` `skills/` + `settings.json`) verlinkt (Eltern-Verzeichnis
  bleibt real, damit die Programme dort Runtime-Dateien anlegen). `claude`
  trackt **nicht** `.claude.json`/sessions/history/cache (Auth/State/Secrets).
- **`scripts/`** = Repo-Werkzeuge, **kein** Stow-Paket: `install.sh`,
  `install-programs.sh`, `update-package-list.sh`, `programs.txt`.
- **Root-Pakete** (`ROOT_PKGS` in `scripts/install.sh`, Ziel `/`): `ly`,
  `systemd-system`, `pacman`, `mkinitcpio` (`/etc/mkinitcpio.conf`).
- **System-Dienste**: `install.sh` bietet optional an, die Units aus
  `SYSTEM_UNITS` per `systemctl enable` (ohne `--now`) zu aktivieren; User-Units
  sind bereits über die gestowten `*.wants`-Links im Paket `systemd-user` aktiv.
- **Nicht gestowt**: `AGENT/` bleibt im Repo-Root (reine Arbeits-/Workflow-
  Dateien: `TODO.md`, `project-health-report.html`) und wird **nicht** verlinkt.
  Da unter `config/` nur Stow-Pakete liegen, entfällt die frühere
  `IGNORE_PKGS`-Liste.
- Eigene Skripte: Paket **`config/usrbin`** → `~/.local/bin` (XDG-Standardort für
  User-Executables, via `.bashrc` im `PATH`; interne Struktur `.local/bin/…`).
  `lib_hypr.sh` ist eine per `source` eingebundene Helfer-Lib
  für die Hyprland-Workspace-Automatisierung (`workspace_slf`,
  `rofi_workspace_manager`). `dotfiles_sync` versioniert `scripts/programs.txt`;
  `update_programs_list` schreibt nach `scripts/programs.txt`.
- **`nvim/`** hat eine **eigene `CLAUDE.md`** (`config/nvim/.config/nvim/CLAUDE.md`)
  mit den nvim-spezifischen Verifikations-Befehlen — für nvim-Änderungen dort
  nachsehen.

## Konventionen & Fallstricke

- Neue Stow-Pakete: Ordner mit gespiegelter Zielstruktur **unter `config/`**
  anlegen; muss das Paket nach `/`, in `ROOT_PKGS` (in `scripts/install.sh`)
  eintragen.
- **`AGENT/` bleibt im Root** und außerhalb der Stow-Logik — bewusst so.
- **Skalierung/Cursor-Env** (QT_SCALE_FACTOR, GDK_SCALE, XCURSOR_SIZE, …) werden
  ausschließlich in `config/hypr/.config/hypr/hyprland.conf` gesetzt, **nicht** in der
  `.bashrc` — nicht erneut duplizieren (sonst rendern Apps je nach Startweg anders).
- Hyprland-Config: Seit 0.55 ist **hyprlang (`.conf`) deprecated** zugunsten der
  **Lua-Config** (API-Global `hl`, geladen aus `~/.config/hypr/hyprland.lua`,
  Quelle unter `config/hypr/.config/hypr/`).
  `hyprland.lua` ist nur noch der **Einstiegspunkt** und lädt per `require()` die
  thematischen Module (`env`, `monitors`, `animations`, `devices`, `keybinds`,
  `looknfeel`, `autostart`) sowie die zentrale `programs.lua` (Programm-Namen).
  Splitting-Muster laut Wiki (`require("modul")`, flach im hypr-Verzeichnis).
  Bei Änderungen das passende Modul pflegen und mit `luac -p <datei>.lua` prüfen;
  formatiert wird mit **stylua** (Tabs). `hyprland.conf` wird von Hyprland bei
  Lua-Nutzung als Stub **autogeneriert** und ist daher **gitignored** — nicht
  bearbeiten. Die alte hyprlang-Config liegt noch in der Git-History bzw. lokal
  als `hyprland.conf.bak`. Konvertierung erfolgte mit `hyprlang2lua`.
- **KeePassXC-DB** (`*.kdbx`) ist per `.gitignore` ausgeschlossen und der
  `config/keepassxc/`-Ordner per `.claudeignore`.
- Commits werden SSH-signiert (`config/git/.config/git/.gitconfig`).
- Zwei Health-/Workflow-Skills schreiben in `AGENT/`:
  `review-and-update-report` (Health-Report) und `implement-todo` (`TODO.md`
  abarbeiten, ein Commit pro Punkt).
