# CLAUDE.md

Hinweise für die Arbeit an diesem Dotfiles-Repo. Kommentar-/Doku-Sprache: **Deutsch**.

## Überblick

Persönliche Dotfiles für Arch Linux mit Hyprland (Wayland), verwaltet über
**GNU Stow**. Jedes Top-Level-Verzeichnis ist ein Stow-Paket, dessen innere
Struktur das Zielverzeichnis spiegelt — meist `$HOME` (z. B.
`alacritty/.config/alacritty/…` → `~/.config/alacritty/…`), bei Root-Paketen `/`
(z. B. `ly/etc/ly/…` → `/etc/ly/…`). Details zu Inhalten/Pfaden: `README.md`.

## Installation & Befehle

- **Verlinken**: `./install.sh` — fragt vor dem Anwenden, führt `stow -R` je Paket
  aus. User-Pakete relativ zu `$HOME`, Root-Pakete (`ROOT_PKGS`) via
  `sudo stow --target=/`. Danach optional `programs.txt` aktualisieren.
- **Paketliste aktualisieren** (ohne Neu-Verlinken): `./update-package-list.sh`.
- **Pakete aus `programs.txt` installieren**: `./install-programs.sh` (nutzt `yay`).
- **Shell-Skripte prüfen** (kein Test-Framework): `bash -n <skript>`; wo vorhanden
  `shellcheck <skript>`.

## Struktur

- Ein Verzeichnis = ein Stow-Paket. Konfig-Pakete: `alacritty`, `bash`, `git`,
  `hypr`, `keepassxc`, `mako`, `mpv`, `rofi`, `scripts`, `typst`, `systemd-user`.
- **Root-Pakete** (`ROOT_PKGS` in `install.sh`, Ziel `/`): `ly`, `systemd-system`.
- **Nicht gestowt** (`IGNORE_PKGS` in `install.sh`): `prompts/` — reine
  Arbeits-/Workflow-Dateien (`TODO.md`, `project-health-report.html`,
  `project-setup.md`), werden **nicht** verlinkt.
- Eigene Skripte: `scripts/.config/scripts/` (→ `~/.config/scripts`, liegt via
  `.bashrc` im `PATH`). `lib_hypr.sh` ist eine per `source` eingebundene Helfer-Lib
  für die Hyprland-Workspace-Automatisierung (`workspace_slf`,
  `rofi_workspace_manager`).
- **`nvim/`** hat eine **eigene `CLAUDE.md`** (`nvim/.config/nvim/CLAUDE.md`) mit
  den nvim-spezifischen Verifikations-Befehlen — für nvim-Änderungen dort nachsehen.

## Konventionen & Fallstricke

- Neue Stow-Pakete: Ordner mit gespiegelter Zielstruktur anlegen; muss das Paket
  nach `/`, in `ROOT_PKGS` eintragen; soll es gar nicht verlinkt werden, in
  `IGNORE_PKGS`.
- **`prompts/` nicht in Stow-Logik aufnehmen** — bewusst ausgeschlossen.
- **Skalierung/Cursor-Env** (QT_SCALE_FACTOR, GDK_SCALE, XCURSOR_SIZE, …) werden
  ausschließlich in `hypr/.config/hypr/hyprland.conf` gesetzt, **nicht** in der
  `.bashrc` — nicht erneut duplizieren (sonst rendern Apps je nach Startweg anders).
- Hyprland-Config: Seit 0.55 ist **hyprlang (`.conf`) deprecated** zugunsten der
  **Lua-Config** (`hyprland.lua`, API-Global `hl`, geladen aus
  `~/.config/hypr/hyprland.lua`). Das Repo enthält beides: `hyprland.lua` (aktiv
  gepflegt) und `hyprland.conf` (Fallback). Bei Änderungen die `.lua` pflegen;
  Lua-Syntax mit `luac -p hyprland.lua` prüfen. Konvertierung erfolgte mit
  `hyprlang2lua`.
- **KeePassXC-DB** (`*.kdbx`) ist per `.gitignore` ausgeschlossen und der
  `keepassxc/`-Ordner per `.claudeignore`.
- Commits werden SSH-signiert (`git/.config/git/.gitconfig`).
- Zwei Health-/Workflow-Skills schreiben in `prompts/`:
  `review-and-update-report` (Health-Report) und `implement-todo` (`TODO.md`
  abarbeiten, ein Commit pro Punkt).
