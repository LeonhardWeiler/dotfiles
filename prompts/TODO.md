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

---

## P12 – Kritische Bewertung aller Configs (auf der Goldwaage)

**Ziel:** Jede Konfiguration wird kritisch geprüft: Ist jede Einstellung/Datei
**berechtigt** (bewusst gesetzt), gibt es **bessere Varianten**, oder ist etwas
**überflüssig** (Default, Rest, toter Code)? Ergebnis wird pro Programm getrennt
in `~/prompts/project-health-report.html` festgehalten (bzw. hier in Findings
überführt). Umsetzung von Fixes erst nach Bewertung.

### Vorgehen je Programm

Für jedes Paket: Datei(en) durchgehen, jede Option in eine Kategorie einordnen —
**behalten** / **ändern (bessere Variante)** / **entfernen (überflüssig/Default)**
— mit kurzer Begründung.

### Prüf-Checkliste pro Programm

- [ ] **alacritty** – Font/Größe/Opacity vs. Defaults; veraltete Keys (Config-
      Format-Änderungen von Alacritty)?
- [ ] **bash** – `.bashrc`: Aliase/Exports nötig? `PROMPT_COMMAND`-Kosten,
      History-Setup, doppelte PATH-Einträge, ungenutzte Env-Vars.
- [ ] **btop** – enthält viel Auto-generiertes; nur bewusst geänderte Keys
      behalten, Rest ggf. auf Default lassen (kleinere, wartbarere Datei).
- [ ] **git** – `.gitconfig`: Signing, Aliase, `GIT_CONFIG_GLOBAL`-Konstrukt;
      unnötige Duplikate?
- [ ] **hypr** – nach Modul-Split (bereits erledigt): pro Modul prüfen; z. B.
      deaktivierte Animationsblöcke (`animations.lua` bei global `enabled=false`)
      — behalten oder entfernen? Hardcodierte Monitor-/PCI-Pfade (Portabilität).
- [ ] **keepassxc** – nur echte Config, keine DB (bereits gitignored) – prüfen.
- [ ] **mako** – Regeln/Style nötig? (siehe auch Report-Frage mako vs. quickshell).
- [ ] **mpv** – `mpv.conf`/`input.conf`: Profile, Hardware-Decoding sinnvoll?
- [ ] **nvim** – eigene `prompts/TODO.md` + Health-Report bereits vorhanden →
      dort vertiefen; hier nur Verweis.
- [ ] **pipewire** – `99-custom.conf`: Quantum/Sample-Rates begründet? Messbarer
      Nutzen vs. Default; potenzielle Xruns bei kleinem `min-quantum=32`.
- [ ] **qt5ct** – `[SettingsWindow] geometry` ist reiner UI-State → entfernbar;
      Fonts/Style behalten.
- [ ] **rofi** – Theme/Keybinds; ungenutzte Modi?
- [ ] **typst** – Paketpfad/Setup nötig?
- [ ] **systemd-user / systemd-system** – jede Unit: noch gebraucht? Ziele/After
      korrekt? `legion-conservation` gerätespezifisch.
- [ ] **ly / pacman** – Root-Pakete: Hook-Trigger minimal & korrekt?

### Erfolgskriterien

- Pro Programm eine Bewertung (behalten/ändern/entfernen) mit Begründung.
- Konkrete, umsetzbare Folge-Tasks für „ändern"/„entfernen".
- Keine Funktionsänderung ohne dokumentierten Grund.
