---
name: create-claude-md
description: Erstellt nach ausführlicher Repo-Analyse eine CLAUDE.md im Projekt-Root, sofern noch keine existiert. Nutze diesen Skill, wenn der User eine CLAUDE.md anlegen/generieren will ("erstelle eine claude.md", "generiere claude.md", "init claude.md", "leg eine claude.md an"). Projekt-unabhängig; Pfade sind relativ zum Repo-Root.
user-invocable: true
---

# CLAUDE.md erstellen

**Zweck:** Lege im Projekt-Root eine `CLAUDE.md` an, die einem Agenten das
Projekt in kompakter Form erklärt (Zweck, Aufbau, Build-/Test-/Lint-Befehle,
Konventionen, Fallstricke). Erstellt wird sie **erst nach einer ausführlichen
Analyse des gesamten Repos** — nicht aus Annahmen.

Dieser Skill ist **projekt-unabhängig**: Er funktioniert in jedem Repository.
Alle Pfade sind relativ zum Repo-Root; führe den Skill aus dem Wurzelverzeichnis
des jeweiligen Projekts aus.

**Ergebnis:** Ein einziger Commit, der ausschließlich `CLAUDE.md` hinzufügt.

---

## Schritt 0 — Nur anlegen, wenn noch keine existiert

Prüfe zuerst, ob bereits eine CLAUDE.md vorhanden ist (Repo-Root `CLAUDE.md`,
auch `.claude/CLAUDE.md` oder eine bestehende `AGENTS.md`).

- **Existiert schon eine** → **nicht überschreiben.** Sag das kurz und biete an,
  sie stattdessen zu aktualisieren — mach das aber nur, wenn der User es
  ausdrücklich möchte. Für die laufende Pflege bei Code-Änderungen sind ohnehin
  die Skills `implement-todo` und `review-and-update-report` zuständig.
- **Existiert keine** → weiter mit Schritt 1.

## Schritt 1 — Projekt ausführlich analysieren

Verschaff dir ein echtes Bild vom Projekt, statt zu raten:

- **Zweck & Art** des Projekts, Hauptsprache(n) und Framework(s).
- **Einstiegspunkte** (z. B. `main`, CLI-Kommandos, Server-Entry, App-Root) und
  die wichtigsten Abläufe.
- **Projektstruktur**: welche Verzeichnisse was enthalten, wo der relevante Code
  liegt, was generiert/fremd/vendored ist.
- **Toolchain & Befehle**: leite den vorgesehenen Package-Manager/Toolchain aus
  Lockfiles/Config ab (z. B. `bun.lock` → Bun, `pnpm-lock.yaml` → pnpm,
  `package-lock.json` → npm, `Cargo.toml` → Cargo, `go.mod` → Go, `Makefile`/
  `justfile` → deren Targets). Rate nicht.
- **Vorhandene Doku** (`README.md`, `CONTRIBUTING.md`, CI-Konfig) — übernimm
  daraus Fakten, dupliziere aber keine langen Passagen.
- **Konventionen & Fallstricke**: Code-Stil, Namensgebung, Commit-Format,
  gespiegelte Logik, die synchron gehalten werden muss, generierte Artefakte.

Verifiziere Befehle, wo es ohne Nebenwirkungen möglich ist (z. B. dass ein
Script in `package.json` wirklich existiert). Trag **nur ein, was du im Repo
belegen kannst** — keine erfundenen Befehle oder Strukturen.

## Schritt 2 — `CLAUDE.md` schreiben

Schreibe knapp, faktisch und für einen Agenten nützlich — keine Marketing-Prosa.
Sinnvolle Abschnitte (nur die, die zum Projekt passen):

- **Überblick** — was das Projekt ist und tut, Sprache/Framework, in 2–4 Sätzen.
- **Setup / Build / Test / Lint** — die konkreten Befehle mit dem korrekten
  Package-Manager. Genau die, die man zum Verifizieren einer Änderung braucht.
- **Projektstruktur** — die wichtigsten Verzeichnisse/Dateien und ihr Zweck.
- **Architektur / zentrale Abläufe** — kurz, nur so viel wie zum Zurechtfinden nötig.
- **Konventionen** — Code-Stil, Namensgebung, Commit-Konventionen, Sprache der
  Doku/Kommentare, sofern erkennbar.
- **Fallstricke / projektspezifische Regeln** — was man leicht falsch macht
  (generierte Dateien nicht von Hand ändern, synchron zu haltende Stellen, …).

Halte es kurz genug, dass es aktuell gehalten werden kann. Wenn eine `README.md`
Details bereits gut abdeckt, verweise darauf, statt sie zu kopieren.

## Schritt 3 — Commit

Erstelle einen Commit, der **nur** `CLAUDE.md` enthält, mit einer aussagekräftigen
Message (z. B. `docs: CLAUDE.md hinzugefügt`). Committe **auf dem aktuellen
Branch** — lege **nicht** ungefragt einen neuen Branch an (außer der User bittet
ausdrücklich darum). Fasse keine anderen Dateien mit an.

## Grundregeln

- **Nichts erfinden** — nur im Repo verifizierbare Fakten.
- **Bestehende CLAUDE.md nie ungefragt überschreiben.**
- Kurz und wartbar halten; Redundanz zur `README.md` vermeiden.
- Melde am Ende knapp, was du aufgenommen hast und in welchem Commit es landete.
