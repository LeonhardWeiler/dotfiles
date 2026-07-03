# Dotfiles – Aufgabenplanung

Sammlung geplanter, noch **nicht umgesetzter** Arbeiten am Dotfiles-Repo.
Ein Commit pro abgearbeitetem Punkt (siehe Skill `implement-todo`).

---

## P11 – Repo-Struktur umbauen: `config/` + `scripts/`

**Ziel:** Klare Trennung im Repo-Root. Danach soll **alles genau wie vorher
funktionieren** (Stow-Verlinkung, Install, Auto-Sync, Hooks).

### Zielstruktur

```
~/dotfiles/
├── README.md            # bleibt im Root
├── CLAUDE.md            # bleibt im Root
├── LICENSE              # bleibt im Root
├── config/              # ALLE Stow-Pakete (die eigentliche Konfiguration)
│   ├── alacritty/ bash/ btop/ git/ hypr/ keepassxc/ mako/ mimeapps/
│   ├── mpv/ nvim/ pipewire/ qt5ct/ rofi/ typst/
│   ├── usrbin/          # bisheriges Paket "scripts" (→ ~/.local/bin) – UMBENENNEN!
│   ├── systemd-user/
│   └── ly/ pacman/ systemd-system/   # Root-Pakete
└── scripts/             # Repo-Werkzeuge (KEINE Stow-Pakete)
    ├── install.sh
    ├── install-programs.sh
    ├── update-package-list.sh
    └── programs.txt
```

### ⚠️ Namenskonflikt zuerst klären

Es gibt bereits ein **Stow-Paket `scripts/`** (verlinkt eigene Skripte nach
`~/.local/bin`). Der neue Ordner `scripts/` soll aber die **Repo-Install-
Werkzeuge** aufnehmen. Beides kann nicht denselben Namen haben.

- **Entscheidung nötig:** Stow-Paket `scripts` → nach `config/` verschieben und
  dort **umbenennen** (Vorschlag: `config/usrbin/` oder `config/localbin/`), da
  „scripts" sonst doppeldeutig ist. Die interne Struktur (`.local/bin/…`) bleibt
  unverändert.

### Schritte

1. `config/` und `scripts/` anlegen; alle Stow-Pakete per `git mv` nach
   `config/` verschieben, Install-Werkzeuge + `programs.txt` nach `scripts/`.
2. **`scripts/install.sh` anpassen:**
   - `DOTFILES_DIR` zeigt weiter auf Repo-Root (ein Verzeichnis über `scripts/`):
     `DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"`.
   - Stow braucht `--dir`: `stow --dir="$DOTFILES_DIR/config" --target="$HOME" <pkg>`
     bzw. für Root-Pakete `--target=/`. Die Paket-Auto-Erkennung iteriert dann
     über `config/*` statt `./*`.
   - `IGNORE_PKGS`/`prompts` entfällt in `config/` (prompts bleibt im Root).
   - `programs.txt`-Regenerierung schreibt nach `scripts/programs.txt`.
3. **`update-package-list.sh`** analog auf `scripts/programs.txt` zeigen lassen.
4. **`~/.local/bin/update_programs_list`** (Skript-Quelle in `config/usrbin/…`):
   `OUT="$DOTFILES/scripts/programs.txt"` statt `$DOTFILES/programs.txt`.
5. **`dotfiles_sync`**: `PATHS=("scripts/programs.txt")` statt `programs.txt`;
   `GENERATORS`-Pfad bleibt (`~/.local/bin/update_programs_list`).
6. **`install-programs.sh`**: Pfad zu `programs.txt` → `scripts/programs.txt`.
7. **`.gitignore` / `.claudeignore`**: Pfade prüfen (z. B. `keepassxc` →
   `config/keepassxc`, `hyprland.conf`-Ignore relativ).
8. **README.md / CLAUDE.md**: Struktur-Abschnitte, Pfad-Tabelle und Befehle
   (`./install.sh` → `./scripts/install.sh`) aktualisieren.
9. **pacman-Hook**: verweist auf `~/.local/bin/update_programs_list` (unverändert
   OK); nur prüfen, dass dessen `OUT`-Pfad stimmt (Schritt 4).

### Erfolgskriterien

- `./scripts/install.sh` verlinkt **alle** Pakete korrekt (User + Root), idempotent.
- `programs.txt` wird an neuer Stelle regeneriert (Hook + `dotfiles_sync` + Install).
- Keine verwaisten Symlinks; `git status` sauber; alle Referenzen umgestellt.
- README/CLAUDE.md beschreiben die neue Struktur vollständig.
