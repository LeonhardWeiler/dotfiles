# CLAUDE.md

Hinweise für die Arbeit an diesem Dotfiles-Repo. Kommentar-/Doku-Sprache: **Deutsch**.

## Überblick

Persönliche Dotfiles für Arch Linux mit Hyprland (Wayland), verwaltet über
**dotbot** (als Git-Submodul unter `dotbot/`). Der Repo-Root trennt **`config/`**
(die Config-Quellen, **flach**: `config/<name>/…`) von **`scripts/`**
(Repo-Werkzeuge). Die Zuordnung Quelle→Ziel steht explizit in
**`install.conf.yaml`** (User-Ziele) und **`root.install.conf.yaml`** (`/etc`).
Beispiele: `config/btop/btop.conf` → `~/.config/btop/btop.conf`,
`config/ly/config.ini` → `/etc/ly/config.ini`. Details zu Inhalten/Pfaden:
`README.md`. Prerequisite: Python 3 + PyYAML (`python-yaml`).

## Installation & Befehle

- **Verlinken (User)**: `./install` — Wrapper um dotbot, nutzt
  `install.conf.yaml`. Erzeugt alle `~/…`-Links, entfernt verwaiste Links via
  `clean` und aktiviert die User-Units per `systemctl --user reenable`.
- **Verlinken (Root/`/etc`)**: `sudo ./install root.install.conf.yaml` —
  dateiweise `/etc`-Links (nie ganze `/etc`-Verzeichnisse) + `reenable` der
  System-Units.
- **Submodul**: `git clone --recurse-submodules …` bzw.
  `git submodule update --init` (dotbot liegt unter `dotbot/`).
- **Paketliste aktualisieren** (ohne Neu-Verlinken): `./scripts/update-package-list.sh`.
- **Pakete aus `programs.txt` installieren**: `./scripts/install-programs.sh` (nutzt `yay`).
- **Shell-Skripte prüfen** (kein Test-Framework): `bash -n <skript>`; wo vorhanden
  `shellcheck <skript>`.

## Struktur

- **`config/`** = flache Config-Quellen: `alacritty`, `bash`, `btop`, `claude`,
  `git`, `hypr`, `keepassxc`, `ly`, `mako`, `mimeapps`, `mkinitcpio`, `mpv`,
  `nvim`, `pacman`, `pipewire`, `qt5ct`, `rofi`, `systemd-system`,
  `systemd-user`, `typst`, `usrbin`. Ganze Verzeichnisse werden als Dir-Symlink
  verlinkt (alacritty, hypr, nvim, rofi, mako, mpv, git, typst, keepassxc); bei
  `btop`/`qt5ct`/`pipewire`/`mimeapps`/`claude` und `systemd-user`/`/etc`-Zielen
  wird bewusst **nur die einzelne Datei** verlinkt (Eltern-Verzeichnis bleibt
  real — App-Runtime bzw. keine Verdeckung von System-Inhalten). `claude`
  trackt **nicht** `.claude.json`/sessions/history/cache (Auth/State/Secrets).
- **`scripts/`** = Repo-Werkzeuge: `install-programs.sh`,
  `update-package-list.sh`, `programs.txt` (das alte `install.sh` ist durch
  `./install`/dotbot ersetzt).
- **`/etc`-Ziele** (in `root.install.conf.yaml`, dateiweise): `ly/config.ini`,
  `mkinitcpio.conf`, `systemd-system/legion-conservation.service`,
  `pacman/dotfiles-programs-list.hook`.
- **System-/User-Dienste**: werden über die `shell`-Direktiven der beiden
  Configs per `systemctl reenable` (System) bzw. `systemctl --user reenable`
  (User: `battery-check.timer`, `dotfiles-sync.service`) (re)aktiviert.
  PipeWire/WirePlumber/figma-agent kommen aus ihren Paket-Presets und werden
  **nicht** getrackt (früher als `*.wants`-Links im Repo — jetzt entfernt).
- **Nicht verlinkt**: `AGENT/` (Arbeits-/Workflow-Dateien) und `dotbot/`
  (Submodul) bleiben im Repo-Root.
- Eigene Skripte: **`config/usrbin`** → `~/.local/bin` (via `.bashrc` im `PATH`).
  `lib_hypr.sh` ist eine per `source` eingebundene Helfer-Lib
  (`workspace_slf`, `rofi_workspace_manager`). `dotfiles_sync` versioniert
  `scripts/programs.txt`; `update_programs_list` schreibt dorthin.
- **`nvim/`** hat eine **eigene `CLAUDE.md`** (`config/nvim/CLAUDE.md`) mit den
  nvim-spezifischen Verifikations-Befehlen — für nvim-Änderungen dort nachsehen.

## Konventionen & Fallstricke

- Neue Config: Datei **flach unter `config/<name>/`** ablegen und einen
  `link:`-Eintrag in `install.conf.yaml` (bzw. `root.install.conf.yaml` für
  `/etc`) hinzufügen. `/etc`-Ziele **immer dateiweise**, nie ganze Verzeichnisse.
- **`AGENT/` und `dotbot/` bleiben im Root** und außerhalb der Link-Logik.
- **Skalierung/Cursor-Env** (QT_SCALE_FACTOR, GDK_SCALE, XCURSOR_SIZE, …) werden
  ausschließlich in `config/hypr/hyprland.conf` gesetzt, **nicht** in der
  `.bashrc` — nicht erneut duplizieren (sonst rendern Apps je nach Startweg anders).
- Hyprland-Config: Seit 0.55 ist **hyprlang (`.conf`) deprecated** zugunsten der
  **Lua-Config** (API-Global `hl`, geladen aus `~/.config/hypr/hyprland.lua`,
  Quelle unter `config/hypr/`).
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
- Commits werden SSH-signiert (`config/git/.gitconfig`).
- Zwei Health-/Workflow-Skills schreiben in `AGENT/`:
  `review-and-update-report` (Health-Report) und `implement-todo` (`TODO.md`
  abarbeiten, ein Commit pro Punkt).
