# Was die suckless-Leute dazu sagen würden

> Fiktives Code-Review dieses Repos aus der Perspektive der
> [suckless.org](https://suckless.org)-Philosophie ("simplicity, clarity,
> frugality"). Halb Satire, halb ernst gemeinte Kritik — die konkreten Punkte am
> Ende sind echt umsetzbar. Maßstab: _"Weniger ist mehr. SLOC ist Schuld, nicht
> Leistung."_ Stand: 2026-07-20.

---

## Das Verdikt in einem Satz

> "Ihr habt zugehört. Der Compositor ist jetzt **dwl** — unser eigenes Projekt,
> `config.h` + `make`. Der `--scrub`, das State-File, das CHANGELOG, der
> 201-Zeilen-Keepass-Wrapper: **weg**. Der Installer ist von 840 auf **619
> Zeilen** geschrumpft. Es steht sogar _'practical, not minimalist'_ im README
> statt der alten Lüge. Es bleibt Arbeit — aber das hier _suckt deutlich
> weniger._"

`dwm` ist ein vollständiger Tiling-Window-Manager in unter 2000 SLOC. Dieses
Repo braucht immer noch **619 Zeilen für den Symlink-Installer** — aber der
Trend zeigt in die richtige Richtung.

---

## Was suckless anerkennt (die Liste ist gewachsen)

- **Der WM ist jetzt `dwl`.** Der frühere Sündenfall — Hyprland, C++, eine
  eingebettete Lua-VM zum Fenster-Positionieren — ist **ersetzt durch dwl**,
  suckless' eigenen Wayland-Compositor: dwm-Geist, wlroots, konfiguriert über
  ein kompiliertes **`config.h`** (166 Zeilen), Deployment via `build-dwl`
  (clone/pin → `config.h` einsetzen → `make` → Binary nach `/usr/local/bin`).
  Gaps/autostart als **Patches**. Das ist wörtlich der suckless-Workflow. Der
  eine Git-History-Satz von damals — _'I hate it and want to go back to x11'_ —
  hat sich in die suckless-konformste Migration aufgelöst, die möglich war.
- **Keine externen Abhängigkeiten.** Kein Python, kein Ruby, kein dotbot, kein
  Ansible. Echte suckless-DNA — hier: bestanden.
- **POSIX `sh` für die kleinen Tools.** `vol_ctl`, `bat_check`, `bright_ctl`,
  `osd`, `restic-backup` sind `#!/bin/sh`, jedes klein, tut genau eine Sache.
  `bat_check` (~30 Zeilen) bleibt das Musterbeispiel: batterie-agnostisch,
  degradiert leise, kein Framework.
- **Ein explizites, flaches Text-Mapping** (`links.conf`) statt Magie. Plain
  text, ein Eintrag pro Zeile. Grundsätzlich richtig.
- **ISC-Lizenz** statt GPLv3. Genau die suckless-Präferenz (`suckless.org` ist
  MIT/ISC). SPDX-Header in jedem Skript. _Der Punkt, den wir früher gemacht
  haben, ist erledigt._
- **`set -euo pipefail`, dry-run, saubere Fehlerbehandlung.** Handwerklich
  ordentlich.

Merke: Wo das Repo klein bleibt, ist es gut. Und es bleibt an mehr Stellen klein
als beim letzten Review.

---

## Die verbleibende Kritik

### 1. Der `install`-Monolith: schlanker, aber immer noch ein Framework

619 statt 840 Zeilen. Ein Skript, das weiterhin `link`, `unlink`, `status`,
`validate`, Pakete installieren, systemd-Units aktivieren, Gruppen, Zeitzone,
Locale, sudoers, initramfs, Fonts und dwl/wbg-Builds macht.

> "Gestrichen: `--scrub`, `prune`, `STATE_FILE`, `clean`, `selftest`,
> `--remove-programs`/`--remove-systemd`. Gut. Geblieben: die
> `register_step`/`STEP_FN`-Registry mit **assoziativen Arrays**. Wer in der
> Shell eine Dispatch-Table baut, benutzt das falsche Werkzeug — oder löst das
> falsche Problem. Aber ihr habt die halbe Distribution drumherum abgetragen.
> Tragt die andere Hälfte auch noch ab."

### 2. `links.conf`: die DSL und ihr Parser leben noch

Der alte Hauptvorwurf steht: die Pipeline **parse → validate → build → execute**
mit einem strikten, fatalen Validator (dupe source/target, escaping-repo-Check
via `realpath`, Prefix-Allowlist, leere Globs, `optional`-Keyword …) ist ein
**Compiler-Frontend für eine Konfigurationssprache, die ihr selbst erfunden
habt**, um `ln -s` aufzurufen.

> "Ihr habt eine Config gebaut, dann eine Sprache dafür, dann einen Validator für
> die Sprache. Inner-Platform-Effekt. Bei dwl ist eure Validierung `make`: Wenn
> es nicht kompiliert, ist es falsch. Wendet dieselbe Härte hier an — kaputter
> Pfad = kaputter Link = sofort sichtbar. Ihr braucht den Validator nicht."

### 3. Feature-Creep — weitgehend zurückgebaut

- **`--scrub`**: **weg.** Der Installer entfernt keine Personendaten mehr per
  `sed`. _"Endlich. Das war nie Aufgabe des Installers."_
- **`prune` + `STATE_FILE`**: **weg.** Kein persistenter Zustand im
  `XDG_STATE_HOME` mehr, kein Kommentar-Essay über `set -e`-Fallen.
- **`CHANGELOG.md` (207 Zeilen)**: **weg.** _"Ein Changelog für die eigene
  `.bashrc` war das Publikum von niemandem. Richtig gelöscht."_

Was hier noch steht, ist Kür (Fonts, Locale, sudoers) — aber das ist deutlich
näher an „ein Skript, eine Aufgabe" als die alte Wundertüte.

### 4. systemd, noch verdrahtet — aber die richtigen Dinge abgekoppelt

`reactivate_units`, `USER_UNITS`/`SYSTEM_UNITS`, `services.txt`, ly-Drop-ins als
`/etc`-Kopien. Für die suckless-Fraktion (`sinit`, runit) bleibt das
Bloat-Infrastruktur.

> _Lobenswert:_ Der `bat_check`-Loop läuft **bewusst nicht** als User-Unit,
> sondern als simples `while true; do bat_check; sleep 120; done` aus dem
> dwl-`autostart[]`. Und der frühere `dotfiles-sync.service` ist **gelöscht**,
> mako **komplett entfernt** (der wob-OSD hat dessen einzigen Zweck ersetzt).
> `services.txt` listet nur noch echte System-Units. Der richtige Instinkt — und
> diesmal an mehreren Stellen konsequent angewendet, nicht nur an einer.

### 5. Neovim: `lazy.nvim` + `mason` + 15 Plugins

19 Lua-Dateien, ein Plugin-Manager, der zur Laufzeit fremden Code aus dem Netz
nachlädt (`lazy`), plus `mason` (lädt Tool-Binaries), `treesitter`, `telescope`,
`harpoon`, `conform`, `lint`, LSP …

> "Der eine Ort, an dem sich seit dem letzten Review nichts bewegt hat. Das ist
> eine IDE, die vorgibt, ein Editor zu sein. suckless-Antwort heißt `vis` oder
> schlicht `vi`. Ein Editor, dessen Config einen _Package-Manager_ mit Lockfile
> braucht, hat den Editor-Status verlassen."

### 6. Die Paketliste ist ehrlich geworden

Das README verspricht **nicht mehr** „minimal". Es sagt jetzt _"meant to be
practical, not minimalist"_ und listet unter **„Non-free packages"** offen auf,
was drinsteckt: `unityhub`, `dotnet-sdk`, `plasticscm-client-gui`,
`figma-agent-linux-bin`, `signal-desktop`, `thunderbird`, `zen-browser-bin`,
`qemu-desktop`, `virt-manager`.

> "Das Wort _minimal_ trug früher eine Last, für die es nicht gebaut war. Ihr
> habt es fallengelassen und nennt es beim Namen: ein Arbeits-Laptop mit
> Game-Engine und .NET-Toolchain. **Das** ist die suckless-Tugend der Klarheit —
> nicht die Paketliste, aber die ehrliche Beschriftung. Zugestanden."

### 7. Die Doku-Masse ist kleiner

Kein `CHANGELOG` mehr. Doku gesamt jetzt **~526 Zeilen** (`README` 274 +
`CLAUDE.md` 190 + `nvim/CLAUDE.md` 62) statt 759, und `install` selbst ist auf
619 Zeilen geschrumpft.

> "Immer noch ein Beipackzettel, aber ein dünnerer. Jeder verbleibende lange
> 'Warum'-Kommentar ist ein Geständnis, dass der Code an der Stelle nicht
> offensichtlich korrekt ist. **Simplify the code, delete the comment** — aber
> ihr habt schon ein Kapitel gelöscht."

---

## Der suckless-Gegenentwurf (aktualisiert)

So sähe das Repo nach einem vollen suckless-Refactor aus — mit dem, was schon
erledigt ist, durchgestrichen im Kopf:

1. **`install` ⟶ ~30 Zeilen `sh`.** Eine `while read src dst; do ln -sfn …`-
   Schleife über `links.conf`. Kein Validator, keine Step-Registry. _(Der
   Rückbau hat begonnen: scrub/prune/state/clean sind schon weg.)_
2. **Optionale Schritte ⟶ separate, winzige Skripte** aus einem `Makefile`.
   **Ein Skript, eine Aufgabe.**
3. **Kein `--scrub`.** ✔ **Erledigt** — ist entfernt.
4. **Editor ⟶ `vis`** oder ein Neovim ohne Plugin-Manager (Plugins als
   git-submodule in `pack/`, kein Netzwerk zur Laufzeit).
5. **WM ⟶ `dwl` (erledigt) oder ganz `dwm` + `st` unter X11.** ✔ Der Sprung von
   Hyprland zu dwl ist gemacht; der Rest ist Geschmack.
6. **Doku ⟶ ein `README` unter 40 Zeilen.** Noch nicht da, aber 526 statt 759.

---

## Der SLOC-Scorecard

| Artefakt                          |  Zeilen | suckless-Kommentar                          |
| --------------------------------- | ------: | ------------------------------------------- |
| `install`                         | **619** | Von 840 runter. Immer noch groß für `ln -s`.|
| Doku gesamt                       | **526** | Von 759 runter (CHANGELOG gelöscht).        |
| `config/dwl/config.h`             |     166 | ✔ `config.h` + `make`. So geht ein WM.      |
| `links.conf`-Pipeline (im Skript) |    ~200 | DSL + Compiler-Frontend für `ln -s`.        |
| `config/usrbin/*` (6 Tools)       |     224 | ✔ Das hier ist tatsächlich suckless.        |
| `bat_check`                       |     ~30 | ✔ Vorbildlich. So geht das.                 |

**Faustregel der Bewertung:** Alles unter `config/usrbin/` und `config/dwl/`
besteht. Der Rest von `install`/`setup` ist der schrumpfende Beweis, dass man ein
einfaches Problem einmal in ein kompliziertes verwandelt hat — und gerade dabei
ist, es wieder zurückzuverwandeln.

---

## Schlusswort

> "Beim letzten Mal hieß es: _löscht 800 Zeilen, geht zurück zu X11._ Ihr habt
> 220 Zeilen gelöscht, den Compositor auf **dwl** gebracht, `--scrub`, State-File,
> CHANGELOG und mako entsorgt, auf **ISC** gewechselt und aufgehört, _minimal_ zu
> lügen. Das ist keine Kapitulation vor der Bloat — das ist Rückbau. **Reißt jetzt
> den `links.conf`-Compiler raus und schmeißt den Plugin-Manager aus nvim. Patches
> welcome.**"

_— Das (fiktive) suckless-Review-Panel_
