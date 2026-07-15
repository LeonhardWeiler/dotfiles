# Was die suckless-Leute dazu sagen würden

> Fiktives Code-Review dieses Repos aus der Perspektive der
> [suckless.org](https://suckless.org)-Philosophie ("simplicity, clarity,
> frugality"). Halb Satire, halb ernst gemeinte Kritik — die konkreten Punkte am
> Ende sind echt umsetzbar. Maßstab: _"Weniger ist mehr. SLOC ist Schuld, nicht
> Leistung."_

---

## Das Verdikt in einem Satz

> "Dependency-freies Bash — respektabel. Aber ihr habt GNU Stow, dotbot **und**
> einen Config-Parser in 840 Zeilen Bash _nachgebaut_, um Symlinks zu setzen,
> und nennt das Ergebnis dann _minimal_, während `unityhub`, `dotnet-sdk` und
> drei Electron-Apps in der Paketliste stehen. **Das sucked.**"

`dwm` ist ein vollständiger Tiling-Window-Manager in unter 2000 SLOC. Dieses
Repo braucht **840 Zeilen allein für den Symlink-Installer** — für eine Aufgabe,
die `ln -s` heißt.

---

## Was suckless anerkennen würde (ja, es gibt was)

Fairerweise: einiges hier trifft die richtige Nerve.

- **Keine externen Abhängigkeiten.** Kein Python, kein Ruby, kein dotbot, kein
  Ansible. Das ist echte suckless-DNA. "Wer für Symlinks eine Runtime
  mitschleppt, hat verloren." — hier: bestanden.
- **POSIX `sh` für die kleinen Tools.** `vol_ctl`, `bat_check`, `bright_ctl`,
  `restic-backup` sind `#!/bin/sh`, jedes unter ~50 Zeilen, tun genau eine
  Sache. `bat_check` (30 Zeilen) ist ein Musterbeispiel: batterie-agnostisch,
  degradiert leise, kein Framework. **Das** ist der Geist.
- **Ein explizites, flaches Text-Mapping** (`links.conf`) statt Magie. Plain
  text, ein Eintrag pro Zeile. Grundsätzlich richtig.
- **`set -euo pipefail`, saubere Fehlerbehandlung, dry-run.** Handwerklich
  ordentlich.

Merke: Wo das Repo klein bleibt, ist es gut. Das Problem beginnt exakt dort, wo
es aufhört, klein zu bleiben.

---

## Die Kritik

### 1. Der `install`-Monolith: ein Framework, das sich als Skript verkleidet

840 Zeilen. Ein Skript, das folgendes _alles_ tut: `link`, `unlink`, `status`,
`clean`, `prune`, `validate`, Pakete installieren, Pakete **entfernen**,
systemd-Units aktivieren/deaktivieren, Gruppen, Zeitzone, Locale, sudoers,
initramfs, Fonts, und Personendaten "scrubben".

> "Das ist kein Installer, das ist eine kleine Distribution. **Do one thing and
> do it well** — ihr macht siebzehn Dinge und dokumentiert sie in 205 Zeilen
> CLAUDE.md, damit ihr euch selbst noch versteht."

Die `register_step`/`SELECTED`/`STEP_FN`-Registry mit Bash-**assoziativen
Arrays** ist der Beweis: Wer in der Shell eine Plugin-Architektur mit einer
Dispatch-Table baut, benutzt das falsche Werkzeug — oder löst das falsche
Problem. suckless-Reflex: _"Assoziative Arrays in Bash sind ein Code-Smell. Sie
sagen dir, dass dein Design eine echte Datenstruktur braucht, also die falsche
Sprache."_

### 2. `links.conf`: ihr habt eine DSL erfunden — und einen Parser dafür

Der eigentliche Sündenfall. Die Pipeline **parse → validate → build → execute**
mit einem _strikten, fatalen Validator_ (`validate_links`, ~70 Zeilen: dupe
source, dupe target, escaping-repo-Check via `realpath`, Prefix-Allowlist,
leere Globs, `optional`-Keyword …) — das ist ein **Compiler-Frontend für eine
Konfigurationssprache, die ihr selbst erfunden habt**, um `ln -s` aufzurufen.

> "Ihr habt eine Config-Datei gebaut, dann eine Sprache für die Config, dann
> einen Validator für die Sprache. Das ist Inner-Platform-Effekt. `config.h` und
> `make` — das ist eure Validierung. Wenn es nicht kompiliert, ist es falsch.
> Fertig."

Der suckless-Weg ist **Source Code als Konfiguration**: kein Runtime-Parsing,
keine DSL, kein Zustand. Die 460 Zeilen um `parse_links`/`validate_links`/
`build_table`/`filter_table`/`prune_stale`/`save_linked_state` herum existieren
nur, weil man beschlossen hat, das Mapping _zur Laufzeit zu interpretieren_
statt es _zu sein_.

### 3. Feature-Creep, kanonisiert

- **`--scrub`**: Ein Installer, der Personendaten aus der Working Copy entfernt,
  git-Identität überschreibt, den restic-Host per `sed` ersetzt und die
  `WLR_DRM_DEVICES`-Zeile löscht. Nützlich? Vielleicht. suckless-Urteil: _"Das
  gehört nicht in den Installer. Das gehört in eine `.example`-Datei, die der
  Fremdnutzer selbst kopiert. Ihr löst ein Social-Problem mit `sed`."_
- **`prune` + `STATE_FILE`**: Ein persistenter Zustand im
  `XDG_STATE_HOME`, um verwaiste Symlinks zu erkennen, plus ein langer Kommentar,
  warum `return 0` das letzte Statement sein muss, sonst bricht `set -e` ab. _Das
  ist Komplexität, die weitere Komplexität gebiert._
- **`--only`/`--exclude`, `CHANGELOG.md` (207 Zeilen) für persönliche
  Dotfiles.** _"Ein Changelog für deine eigene `.bashrc`? Wer ist das Publikum?"_

### 4. Der Elefant: Hyprland (und Wayland überhaupt)

Hier hört bei suckless der Spaß auf. Hyprland ist C++, mehrere hunderttausend
Zeilen, animiert, plugin-fähig, feature-getrieben — **die exakte Antithese zu
`dwm`**. Und Wayland selbst gilt in der Szene als überkomplexes Protokoll-Monster
mit einem Compositor-pro-Feature-Problem.

> "Ein Compositor, der eine **Lua-VM** einbettet, um Fenster zu positionieren
> (`hl.env(...)`, `require('keybinds')`), ist kein Window-Manager, das ist eine
> Applikationsplattform. `dwm` + `st` unter X11 tut dasselbe in weniger Speicher
> als euer Splash-Screen. Und — Zitat aus eurer eigenen Git-History:
> _'time for a new install. I hate it and want to go back to x11'_ — **ihr wisst
> es doch selbst.**"

Ironischerweise ist der eine Commit-Message-Satz die suckless-konformste Zeile
im ganzen Repo.

### 5. systemd, tief verdrahtet

`reactivate_units`, `USER_UNITS`/`SYSTEM_UNITS`, `services.txt`, `daemon-reload`,
ly-Drop-ins als `/etc`-Kopien wegen früher Boot-Reihenfolge. Für die suckless-
Fraktion (die `sinit`, runit, klein-init bevorzugt) ist das die
Bloat-Infrastruktur, gegen die man antritt. _Lobenswert immerhin_: Der
`bat_check`-Loop und `dotfiles_sync` laufen **bewusst nicht** als User-Units,
sondern als simple Kommandos aus dem Hyprland-Autostart. Das ist der richtige
Instinkt — nur an genau einer Stelle konsequent angewendet.

### 6. Neovim: `lazy.nvim` + `mason` + 15 Plugins

19 Lua-Dateien, ein Plugin-Manager, der zur Laufzeit fremden Code aus dem Netz
nachlädt (`lazy`), plus `mason` (lädt Tool-Binaries), `treesitter`, `telescope`,
`harpoon`, `conform`, `lint`, LSP, roslyn …

> "Das ist eine IDE, die vorgibt, ein Editor zu sein. suckless-Antwort heißt
> `vis` oder schlicht ` vi`. Ein Editor, dessen Config einen _Package-Manager_
> mit Lockfile braucht, hat den Editor-Status verlassen."

### 7. Die Paketliste sagt das Gegenteil des README

Das README verspricht _"a minimal and fast workflow"_. `programs.txt` liefert:
`unityhub`, `dotnet-sdk`, `plasticscm-client-gui`, `figma-agent-linux-bin`,
`signal-desktop` (Electron), `thunderbird`, `zen-browser-bin` (Firefox-Fork),
`qemu-desktop`, `virt-manager`.

> "Das Wort _minimal_ trägt hier eine Last, für die es nicht gebaut wurde. Das
> ist ein Arbeits-Laptop mit Game-Engine und .NET-Toolchain. Nennt es ehrlich:
> _'meine praktischen Dotfiles'_. **Minimal ist es nicht.**"

### 8. Die Doku-Masse ist ein Symptom, keine Lösung

759 Zeilen Doku (`README` 285 + `CLAUDE.md` 205 + `CHANGELOG` 207 +
`nvim/CLAUDE.md` 62), plus ein `install`-Skript, das zu ~40 % aus Kommentaren
besteht, die erklären, _warum_ eine `set -e`-Falle so umschifft werden muss.

> "Gute Software braucht keinen Beipackzettel. Jeder lange 'Warum'-Kommentar in
> `prune_stale` ist ein Geständnis, dass der Code an dieser Stelle nicht
> offensichtlich korrekt ist. **Simplify the code, delete the comment.**"

### 9. Lizenz-Fußnote

GPLv3 mit SPDX-Headern in jedem Skript. suckless-Präferenz ist ISC/MIT
(`suckless.org` ist MIT-lizenziert) — _"GPL ist mehr Bürokratie, als 30 Zeilen
`sh` verdienen"_. Kleiner Punkt, aber sie würden ihn machen.

---

## Der suckless-Gegenentwurf

So sähe das Repo nach einem suckless-Refactor aus:

1. **`install` ⟶ ~30 Zeilen `sh`.** Eine `while read src dst; do ln -sfn …`-
   Schleife über `links.conf`. Kein Validator (falscher Pfad = kaputter Link =
   sofort sichtbar). Kein `prune`, kein State-File, kein Step-Registry.
2. **Optionale Schritte ⟶ separate, winzige Skripte.** `setup-fonts`,
   `setup-locale`, `setup-groups` — je 5 Zeilen, aus einem `Makefile` oder einem
   Dreizeiler-Runner aufgerufen. **Ein Skript, eine Aufgabe.**
3. **Kein `--scrub`.** Stattdessen `config/git/config.example` + eine Zeile im
   README. Personendaten trackt man gar nicht erst.
4. **Editor ⟶ `vis`** oder ein Neovim ohne Plugin-Manager (Plugins als
   git-submodule in `pack/`, kein Netzwerk zur Laufzeit).
5. **WM ⟶ `dwm` + `st` + `dmenu` + `slock` unter X11.** Konfiguration via
   `config.h`, Deployment via `make install`. (Das schreibt euch die
   Git-History ja selbst vor.)
6. **Doku ⟶ ein `README` unter 40 Zeilen.** Wenn du 759 Zeilen brauchst, um dein
   Setup zu erklären, ist das Setup das Problem.

---

## Der SLOC-Scorecard

| Artefakt                          |  Zeilen | suckless-Kommentar                        |
| --------------------------------- | ------: | ----------------------------------------- |
| `install`                         | **840** | Ein WM (`dwm`) ist kleiner. Für Symlinks. |
| Doku gesamt                       | **759** | Beipackzettel für Selbstgebautes.         |
| `CHANGELOG.md`                    |     207 | Changelog. Für deine Dotfiles.            |
| `links.conf`-Pipeline (im Skript) |    ~460 | DSL + Compiler-Frontend für `ln -s`.      |
| `config/usrbin/*` (6 Tools)       | **237** | ✔ Das hier ist tatsächlich suckless.      |
| `bat_check`                       |      30 | ✔ Vorbildlich. So geht das.               |

**Faustregel der Bewertung:** Alles unter `config/usrbin/` besteht. Alles in
`install`/`setup`/Doku ist der Beweis, dass man ein einfaches Problem in ein
kompliziertes verwandelt hat.

---

## Schlusswort

> "Ihr habt die halbe Miete: keine Abhängigkeiten, kleine `sh`-Tools, ein
> explizites Mapping. Dann habt ihr eine Distribution drumherum gebaut, einen
> Compositor mit eingebautem Interpreter installiert und `unityhub` _minimal_
> genannt. **Löscht 800 Zeilen. Geht zurück zu X11 — ihr wolltet das ja
> ohnehin. Patches welcome.**"

_— Das (fiktive) suckless-Review-Panel_
