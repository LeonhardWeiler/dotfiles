# CLAUDE.md

Hinweise für die Arbeit an diesem Dotfiles-Repo. Kommentar-/Doku-Sprache: **Deutsch**.

## Überblick

Persönliche Dotfiles für Arch Linux mit Hyprland (Wayland), verwaltet über ein
**eigenes, abhängigkeitsfreies Symlink-Skript** (`./install`, reines Bash). Der
Repo-Root trennt **`config/`** (die Config-Quellen, **flach**: `config/<name>/…`)
von **`scripts/`** (Repo-Werkzeuge). Die Zuordnung Quelle→Ziel steht explizit in
**`links.conf`** (eine Zeile pro Link, zwei Spalten: `<quelle-im-repo> <ziel>`;
`~`-Ziele = User, `/etc/…`-Ziele = System via sudo). Beispiele:
`config/btop/btop.conf` → `~/.config/btop/btop.conf`,
`config/ly/config.ini` → `/etc/ly/config.ini`. Details zu Inhalten/Pfaden:
`README.md`. Keine externen Abhängigkeiten (kein Python, kein dotbot).

## Installation & Befehle

- **Verlinken**: `./install` (= `./install link`) — legt alle Links aus
  `links.conf` an/frischt sie auf und reaktiviert danach die systemd-Units
  (self-healing). `~/…`-Ziele ohne, `/etc/…`-Ziele per sudo (fragt bei Bedarf
  nach dem Passwort). Optionen: `--user-only` (nur `~`, kein sudo), `--no-units`
  (systemd überspringen), `-n/--dry-run` (nur anzeigen), `--force` (reale
  Datei/Verzeichnis am Ziel nach `.bak` sichern und ersetzen — sonst bleiben
  reale Ziele geschützt; existierende Symlinks werden ohnehin ersetzt).
- **Entfernen**: `./install unlink` — entfernt die von uns verwalteten Symlinks
  (nur echte Symlinks auf unsere Quellen; reale Dateien/fremde Links bleiben).
- **Status**: `./install status` — zeigt pro Eintrag ok / fremder Link / echte
  Datei / fehlt.
- **Backups aufräumen**: `./install clean` — löscht die von `--force` angelegten
  `.bak`-Sicherungen der verwalteten Ziele (inkl. `*.bak.<zeitstempel>`; fremde
  `.bak` bleiben unangetastet). Mit `-n` vorher anzeigen.
- **Paketliste aktualisieren** (ohne Neu-Verlinken): `./scripts/update-package-list.sh`.
- **Pakete aus `programs.txt` installieren**: `./scripts/install-programs.sh` (nutzt `yay`).
- **Shell-Skripte prüfen** (kein Test-Framework): `bash -n <skript>`; wo vorhanden
  `shellcheck <skript>`.

## Struktur

- **`config/`** = flache Config-Quellen: `alacritty`, `bash`, `btop`, `claude`,
  `git`, `hypr`, `keepassxc`, `locale`, `logind`, `ly`, `mako`, `mimeapps`,
  `mkinitcpio`, `mpv`, `nvim`, `pacman`, `pipewire`, `qt5ct`, `rofi`,
  `systemd-system`, `systemd-user`, `typst`, `usrbin`, `vconsole`. Ganze
  Verzeichnisse werden als Dir-Symlink
  verlinkt (alacritty, hypr, nvim, rofi, mako, mpv, git, typst, keepassxc); bei
  `btop`/`qt5ct`/`pipewire`/`mimeapps`/`claude` und `systemd-user`/`/etc`-Zielen
  wird bewusst **nur die einzelne Datei** verlinkt (Eltern-Verzeichnis bleibt
  real — App-Runtime bzw. keine Verdeckung von System-Inhalten). `usrbin` wird
  **datei­weise per Glob** (`config/usrbin/*`) nach `~/.local/bin` verlinkt, damit
  das Verzeichnis real bleibt und Fremd-Einträge (z. B. `claude`) erhalten
  bleiben. `claude`
  trackt **nicht** `.claude.json`/sessions/history/cache (Auth/State/Secrets).
- **`scripts/`** = Repo-Werkzeuge: `install-programs.sh`,
  `update-package-list.sh`, `programs.txt` (das alte `install.sh`/`migrate.sh`
  ist durch `./install` + `links.conf` ersetzt).
- **`/etc`-Ziele** (in `links.conf`, dateiweise, `/etc/…`-Zielpfad): `ly/config.ini`,
  `mkinitcpio.conf`, `systemd-system/legion-conservation.service`,
  `pacman/dotfiles-programs-list.hook`, `vconsole/vconsole.conf`,
  `locale/locale.conf`, `pacman/pacman.conf` (→ `/etc/pacman.conf`),
  `logind/logind.conf` (→ `/etc/systemd/logind.conf`).
- **System-/User-Dienste**: werden vom `install`-Skript nach dem Verlinken per
  `systemctl enable` (System) bzw. `systemctl --user enable` (User:
  `battery-check.timer`, `dotfiles-sync.service`) aktiviert — die Unit-Listen
  stehen oben im Skript (`USER_UNITS` / `SYSTEM_UNITS`). Bewusst `enable`, **nicht**
  `reenable`: unsere Unit-Dateien sind Symlinks (linked units), und `reenable`
  würde beim internen `disable` genau diesen Unit-Symlink löschen. `SYSTEM_UNITS`
  enthält nur real existierende System-Units — pipewire/wireplumber (User-Scope)
  und swtpm (socket-aktiviert) gehören **nicht** dazu.
  PipeWire/WirePlumber/figma-agent kommen aus ihren Paket-Presets und werden
  **nicht** getrackt (früher als `*.wants`-Links im Repo — jetzt entfernt).
- **Nicht verlinkt**: `AGENT/` (Arbeits-/Workflow-Dateien) bleibt im Repo-Root.
- Eigene Skripte: **`config/usrbin/*`** → `~/.local/bin` (dateiweise, via `.bashrc`
  im `PATH`).
  `lib_hypr.sh` ist eine per `source` eingebundene Helfer-Lib
  (`workspace_slf`, `rofi_workspace_manager`). `dotfiles_sync` versioniert
  `scripts/programs.txt`; `update_programs_list` schreibt dorthin.
- **`nvim/`** hat eine **eigene `CLAUDE.md`** (`config/nvim/CLAUDE.md`) mit den
  nvim-spezifischen Verifikations-Befehlen — für nvim-Änderungen dort nachsehen.

## Konventionen & Fallstricke

- Neue Config: Datei **flach unter `config/<name>/`** ablegen und eine Zeile
  `<quelle-im-repo>  <ziel>` in `links.conf` hinzufügen. `/etc`-Ziele **immer
  dateiweise** (voller `/etc/…`-Zielpfad), nie ganze Verzeichnisse. Soll ein
  Ziel-Verzeichnis real bleiben und nur einzelne Dateien darin verlinkt werden,
  die Quelle auf `/*` enden lassen (Glob; verlinkt jeden Eintrag nach
  `<ziel>/<name>`) — siehe `config/usrbin/*`.
- **`AGENT/` bleibt im Root** und außerhalb der Link-Logik.
- **Skalierung/Cursor-Env** (QT_SCALE_FACTOR, GDK_SCALE, XCURSOR_SIZE, …) werden
  ausschließlich in `config/hypr/env.lua` (via `hl.env(...)`) gesetzt, **nicht** in
  der `.bashrc` — nicht erneut duplizieren (sonst rendern Apps je nach Startweg
  anders). (`hyprland.conf` ist nur der gitignorierte, autogenerierte Stub.)
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
