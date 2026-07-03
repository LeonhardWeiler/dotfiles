---
name: implement-todo
description: Arbeite die Punkte aus AGENT/TODO.md der Reihe nach ab und committe nach jedem Punkt. Nutze diesen Skill, wenn der User die TODO-Liste umsetzen/abarbeiten will ("arbeite die todos ab", "setze die punkte aus todo.md um", "implement todo"). Projekt-unabhängig; Pfade sind relativ zum Repo-Root.
user-invocable: true
---

# TODO-Punkte abarbeiten & einzeln committen

**Zweck:** Arbeite die Punkte aus `AGENT/TODO.md` der Reihe nach ab und setze
jeden im Code um. Nach **jedem** Punkt folgt ein eigener Commit.

Dieser Skill ist **projekt-unabhängig**: Er funktioniert in jedem Repository,
das eine `AGENT/TODO.md` verwendet. Alle Pfade sind relativ zum Repo-Root;
führe den Skill aus dem Wurzelverzeichnis des jeweiligen Projekts aus.

**Kontext:** Die Punkte in `TODO.md` sind häufig die Reaktionen/Entscheidungen des
Users zu den Findings im Health-Report `AGENT/project-health-report.html`
(z. B. „ux-2 fix", „cq-1 fix"). Eine ID wie `UX-2` verweist auf die gleichnamige
Finding-Karte im Report — lies dort Beschreibung + Empfehlung, wenn ein Punkt
darauf Bezug nimmt.

---

## Projekt-Setup & Verifikation (falls du die Codebase noch nicht kennst)

Verschaff dir zuerst ein Bild vom Projekt, statt Annahmen zu treffen:

- Lies vorhandene Anleitungen wie `README.md`, `CLAUDE.md`, `AGENTS.md` oder
  `CONTRIBUTING.md` — besonders Abschnitte zu Entwicklung/Tests/Build.
- Ermittle **die projekteigenen Verifikations-Befehle** aus den Projektdateien
  (z. B. `package.json`-Scripts, `Makefile`, `justfile`, `Cargo.toml`,
  `go.mod`, `pyproject.toml`, CI-Konfiguration). Nutze **den im Projekt
  vorgesehenen Package-Manager/Toolchain** — rate nicht, sondern leite ihn aus
  Lockfiles/Config ab (z. B. `bun.lock` → Bun, `pnpm-lock.yaml` → pnpm,
  `package-lock.json` → npm).
- Typische Verifikations-Schritte, sofern im Projekt vorhanden: **Formatierung/
  Lint**, **Typecheck**, **Tests**, **Build**. Führe jeweils nur die für die
  geänderte Seite/Sprache relevanten aus.
- Beachte projektspezifische Konsistenz-Regeln (z. B. Gespiegelte Logik, die an
  mehreren Stellen synchron gehalten werden muss) — solche Hinweise stehen meist
  in `CLAUDE.md`/`README.md`.

## Bevor du startest

> **Fehlende Dateien/Ordner anlegen:** Existiert eine in diesem Skill genannte
> Datei oder ein Ordner noch nicht (z. B. Der `AGENT/`-Ordner, `AGENT/TODO.md`
> oder `AGENT/project-health-report.html`), **lege sie an**, statt abzubrechen.
> Ist `AGENT/TODO.md` neu oder leer, gibt es nichts abzuarbeiten — sag das kurz,
> statt zu raten.

1. Lies `AGENT/TODO.md` vollständig und ordne jedem Punkt zu, was konkret zu tun
   ist (ziehe bei Bedarf die passende Finding-Karte im Health-Report heran).
2. **Erstelle zuerst einen kurzen Plan** (ein Commit pro Punkt) und nenne ihn.
3. **Stelle Rückfragen**, wenn ein Punkt mehrdeutig ist oder eine echte
   Design-Entscheidung nötig ist — bevor du anfängst, nicht mittendrin.

## Pro Punkt (in Reihenfolge)

1. **Umsetzen** — nimm die nötigen Code-Änderungen vor. Bleib beim Scope des Punkts;
   fasse keine unabhängigen Änderungen mit an.
2. **Verifizieren** — vor dem Commit lokal grün machen (projekteigene Befehle, siehe
   oben; nur die betroffene Seite/Sprache prüfen). Wenn ein Verhalten neu/geändert
   ist, ergänze oder aktualisiere einen Test, sofern das Projekt Tests hat.
3. **Committen** — ein eigener, fokussierter Commit **nur** mit den Dateien dieses
   Punkts und einer aussagekräftigen Commit-Message (kurzer Präfix, der den Punkt
   benennt, z. B. `ux-2 fix: …`). Committe **auf dem aktuellen Branch** — lege
   **nicht** ungefragt einen neuen Branch an (außer der User bittet ausdrücklich
   darum).

## README/Doku pflegen

Wenn ein Punkt dokumentiertes Verhalten in der Projekt-Dokumentation ändert
(`README.md` o. Ä.: Features, Sicherheits-/Header-Details, Protokoll, bewusste
Entscheidungen), aktualisiere die Doku und committe diese Änderung **separat
danach**.

## CLAUDE.md pflegen

Genauso wie beim README: Wenn ein Punkt eine Funktion, ein Verhalten, einen
Befehl (Build/Test/Lint), die Projektstruktur oder eine Konvention ändert, die in
`CLAUDE.md` dokumentiert ist, **aktualisiere die `CLAUDE.md` entsprechend** und
committe diese Änderung **separat danach**. Existiert (noch) keine `CLAUDE.md`,
lege hier keine an — dafür ist der Skill `create-claude-md` zuständig.

## Health-Report pflegen

Wenn ein umgesetzter Punkt ein Finding in
`AGENT/project-health-report.html` behebt oder dessen Bewertung ändert,
aktualisiere den Report entsprechend: gelöste Findings **entfernen** (nicht
abhaken), Zähler/Inhaltsverzeichnis konsistent halten. Neu entdeckte Probleme, die
du nicht umsetzt, dürfen als Finding im Report ergänzt werden.

## Grundregeln

- **Ein Commit pro TODO-Punkt.** Vermische keine Punkte in einem Commit.
- Fasse Dateien, die nicht zum aktuellen Punkt gehören, nicht an (insb. Andere
  Arbeitsdateien im `AGENT/`-Ordner nicht ungefragt committen).
- Melde am Ende knapp, was pro Punkt geändert und in welchem Commit es gelandet ist.
