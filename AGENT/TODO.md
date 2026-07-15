# TODO — Selbstverbesserung nach den Reviews

Synthese aus `suckless.md`, `stallman.md` und `smith.md`, gegen den **echten**
Repo-Zustand geprüft. Stand nach Umsetzung: **Abschnitte 1–4 erledigt.**

---

## Zuerst prüfen: die Reports irren teilweise (nicht abarbeiten, nur wissen)

Mehrere Kritikpunkte waren veraltet oder falsch — **kein Handlungsbedarf**:

- **Hyprland-Eye-Candy** (smith #1): `looknfeel.lua` hat bereits `rounding = 0`
  und **Animationen global deaktiviert**. Der „minimal mode" existiert schon.
- **SPDX-Header** (stallman #8): `install` und alle `config/usrbin/*` /
  `wallpaper/*.sh` tragen bereits `SPDX-License-Identifier`. Erledigt.
- **CI auf GitHub / `gh`-CLI / `validate.yml` / Selftest** (stallman #2,
  smith #2): existiert **nicht**. Kein `.github/`, kein `selftest` im Skript.
- **`dotfiles-sync.service` / `battery-check.timer`** (smith #4): existieren
  nicht — laufen bereits als simple Kommandos aus dem Hypr-Autostart.
- **`rofi_keepassxc` (201 Zeilen)** (smith #6): existiert nicht in `usrbin/`.
- **GNU/Linux-Naming** (stallman §7): README & CLAUDE.md schreiben bereits
  durchgängig „GNU/Linux". Bei der Umsetzung nachgeprüft — nichts zu tun.

---

## 1. Persönliche Daten — Scrub-Option entfernt (statt Daten auslagern)

**Entscheidung des Owners:** Persönliche Daten bleiben getrackt wie bisher; nur
die Scrub-Mechanik (die sie beim Fremd-Deploy entfernt) wurde ausgebaut.

- [x] `config/git/config` unangetastet lassen (Identität bleibt getrackt).
- [x] `config/usrbin/restic-backup` unangetastet lassen.
- [x] `config/hypr/env.lua` unangetastet lassen (GPU-Pin bleibt).
- [x] **`do_scrub`, Owner-Prompt und `--scrub`/`--no-scrub`-Tri-State aus
      `install` entfernt** (README/CLAUDE.md nachgezogen). *(commit)*

## 2. Installer verschlankt — 840 → 592 Zeilen (−30 %)

- [x] `--remove-programs` (`do_programs_remove`) entfernt. *(commit)*
- [x] `--remove-systemd` (`do_systemd_disable`) entfernt. *(commit)*
- [x] `--only` / `--exclude` (`filter_table`, `name_of`) entfernt. *(commit)*
- [x] `prune` + `STATE_FILE` (`prune_stale`, `save_linked_state`, `ALL_TGTS`)
      entfernt. *(commit)*
- [x] `clean` (`.bak`-Löschen) entfernt. *(commit)*
- [x] Validator konservativ getrimmt: Repo-Escape- und Duplicate-Source-Check
      raus; fehlendes Target, Source-Existenz, Prefix-Allowlist, Duplicate-Target
      und leerer Glob bleiben (positiv/negativ getestet). *(commit)*
- [x] „Keep it lean"-Leitplanke statt einer unehrlichen „< 300 Zeilen"-Notiz
      an den Skriptkopf. *(commit)*

## 3. Doku & Ehrlichkeit

- [x] `CHANGELOG.md` (207 Zeilen) entfernt — git log ist die History. *(commit)*
- [x] README: „minimal"-Overclaim ersetzt durch „practical, not minimalist".
      *(commit)*
- [x] README: Abschnitt **„Non-free packages"** ergänzt (unityhub,
      plasticscm, figma-agent + firmware-Blobs). *(commit)*

## 4. Kleinigkeiten

- [x] GNU/Linux-Naming — war bereits durchgängig korrekt (siehe oben).
- [x] Lange „Warum"-Kommentare reduziert — ergab sich aus den Streichungen in
      Abschnitt 2 (u. a. der `set -e`/`return 0`-Kommentar in `prune_stale`
      fiel mit `prune` weg). Verbleibende Kommentare tragen echte Rationale.

---

## Optional — größere Wertentscheidungen (NICHT für `implement-todo`)

Lebens-/Hardware-Entscheidungen, keine Commits. Nur zur Reflexion:

- **Terminal-Produktivität ergänzen** (smith #7): ein `newsboat`- oder
  `lf`-Setup passt besser zum Ethos als weiteres Theming.
- **Neovim ohne Plugin-Manager** (suckless #6): Plugins als git-submodule in
  `pack/`, kein `lazy`/`mason`-Nachladen zur Laufzeit. Großer Umbau.
- **systemd** (smith #4): die 10 aktivierten Units sind echte System-Services —
  kaum reduzierbar ohne Distro-/Init-Wechsel. Realistisch: so lassen.
- **Wayland/Hyprland → dwm/st unter X11** (suckless #4, smith #1): passt sogar
  zu deiner eigenen Commit-Message. Radikal, aber ehrlich erwogen.
- **Freiheit** (stallman): Arch → **Parabola GNU/Linux-libre**, `linux` →
  `linux-libre`, GitHub → **Codeberg/Forgejo**, Claude/SaaSS → lokales freies
  Modell. Je weiter unten, desto größer der Eingriff.
