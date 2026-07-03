---
name: review-and-update-report
description: Vollständiger Projekt-Review (frischer Scan) und Aktualisierung des Health-Reports AGENT/project-health-report.html; committet ausschließlich diesen Report, keine Code-Änderungen. Nutze diesen Skill, wenn der User einen Projekt-Review/Health-Check will oder den Report aktualisieren möchte ("review das projekt", "update den report", "health-check"). Projekt-unabhängig; Pfade sind relativ zum Repo-Root.
user-invocable: true
---

# Projekt-Review durchführen & Health-Report aktualisieren

**Zweck:** Führe einen vollständigen, frischen Review des gesamten Projekts durch
und bringe den Health-Report `AGENT/project-health-report.html` auf den
aktuellen Stand. Es werden **keine** Code-Änderungen vorgenommen — nur der Report
wird angepasst und committet.

Dieser Skill ist **projekt-unabhängig**: Er funktioniert in jedem Repository.
Alle Pfade sind relativ zum Repo-Root; führe den Skill aus dem Wurzelverzeichnis
des jeweiligen Projekts aus.

**Ergebnis:** Ein einziger Commit, Der ausschließlich
`AGENT/project-health-report.html` ändert.

> **Fehlende Dateien/Ordner anlegen:** Existiert eine in diesem Skill genannte
> Datei oder ein Ordner noch nicht (z. B. Der `AGENT/`-Ordner oder
> `AGENT/project-health-report.html` selbst), **lege sie an**, statt
> abzubrechen. Erzeuge den Report dabei mit der weiter unten beschriebenen
> HTML-Grundstruktur (Titel, Meta-Zeile mit Datum/Branch, Summary-Zähler,
> Inhaltsverzeichnis, Karten mit Schweregrad-Badges, Legende) und den drei
> Abschnitten (Offene Findings · Was schon stark ist · Bewusst entschieden).

---

## Schritt 1 — Projekt vollständig analysieren

- Verschaff dir zuerst einen Überblick über Aufbau und Zweck des Projekts (Sprache,
  Framework, Einstiegspunkte, vorhandene Doku wie `README.md`/`CLAUDE.md`).
- Scanne das **gesamte** Projekt neu (Quellcode + Config/CI/Docs/Tests).
- Bewerte den **aktuellen Codestand**, nicht frühere Report-Versionen. Verifiziere
  jedes bestehende Finding gegen den echten Code, bevor du es behältst.
- Wenn das Projekt Format-/Lint-/Test-/Build-Befehle vorsieht, prüfe (soweit ohne
  Nebenwirkungen möglich), ob diese grün sind — ein gebrochenes Gate ist selbst ein
  Finding. Führe **keine** Code-Änderungen durch, um sie zu reparieren.
- Achte insbesondere auf:
  - Bugs & Korrektheit
  - Security (Auth, Input-Validierung, Header, Rate-Limits, Leaks)
  - Performance
  - UX & UI-/UX-Konsistenz
  - Accessibility (A11y)
  - Code-Qualität, Wartbarkeit, Architektur, technische Schuld
  - Projektstruktur & Sauberkeit
  - Fehlende oder brüchige Tests
  - Dokumentationslücken
  - Sonstiges Verbesserungspotenzial

Prüfe dabei auch die **`CLAUDE.md`** (falls vorhanden) gegen den aktuellen Code:
Stimmen die dort dokumentierten Funktionen, Befehle (Build/Test/Lint),
Projektstruktur und Konventionen noch? Eine **veraltete** `CLAUDE.md` (z. B. Weil
sich eine Funktion geändert hat) oder eine **fehlende** `CLAUDE.md` erfasst du als
Dokumentations-Finding (`DOC-*`) mit der Empfehlung, sie zu aktualisieren bzw.
via `create-claude-md` anzulegen. Dieser Skill nimmt **selbst keine** Änderung an
der `CLAUDE.md` vor — er dokumentiert das nur im Report.

### Zentrale Nutzer-Flows aktiv durchspielen (Pflicht)

Verlass dich **nicht nur auf statisches Lesen** — identifiziere die zentralen
Nutzer-/Nutzungs-Flows der Anwendung (die Haupt-Einstiegspunkte und die wichtigsten
Abläufe darin) und geh sie durch. Achte gezielt auf Reibung, Sackgassen, fehlendes
Feedback und Inkonsistenzen. Solche Erkenntnisse als `UX-*`-Findings erfassen.

- Ermittle die relevanten Flows aus dem Projekt selbst (z. B. Screens/Seiten,
  CLI-Kommandos, API-Endpunkte, Handler) — je nach Art der Anwendung.
- Spiele **jeden Hauptflow von Anfang bis Ende** durch, inkl. Verzweigungen.
- Denk an **Randfälle**: Fehlerzustände, unterbrochene/wiederaufgenommene Abläufe,
  fehlende Verbindung/Ressourcen, ungültige Eingaben, destruktive Aktionen und deren
  Bestätigung, gleichzeitige/verschachtelte Zustände.

Wenn möglich, die Anwendung dazu **real starten** und die Flows tatsächlich
ausführen bzw. per Screenshot prüfen (nutze die projekteigenen Start-Befehle);
andernfalls sie anhand des Codes (Einstiegspunkte, Views, Handler) sorgfältig
mental durchspielen. Frag dich bei jedem Schritt: Was möchte der Nutzer hier tun,
kann es aber nicht? Wo hängt er fest? Fehlt eine Rückmeldung oder Bestätigung?

## Schritt 2 — `AGENT/project-health-report.html` aktualisieren

Passe **ausschließlich** diese Datei an. Behalte ihre bestehende HTML-Struktur und
ihr Styling bei (Titel, Meta-Zeile mit Datum/Branch, Summary-Zähler,
Inhaltsverzeichnis, Karten mit Schweregrad-Badges, Legende).

Regeln für den Inhalt:

- Der Report ist eine **Momentaufnahme** (Health-Check) — er enthält **keine Historie**.
- **Erledigte oder nicht mehr relevante Findings vollständig löschen.** Nicht als
  „Done/Completed" markieren, nicht archivieren — einfach entfernen.
- **Neue Erkenntnisse** aus dem Scan als Findings ergänzen.
- **Bestehende Findings aktualisieren**, wenn sich ihre Bewertung geändert hat.
- Jedes Finding hat: eine kurze ID, einen Schweregrad
  (`kritisch` → `hoch` → `mittel` → `niedrig` → `info`), die betroffene
  Datei/Stelle, eine knappe Beschreibung und eine konkrete Empfehlung.
- Sortiere/priorisiere klar von **kritisch → optional**.
- Halte die Summary-Zähler, das Inhaltsverzeichnis und die Abschnittsnummern
  **konsistent** mit den tatsächlich vorhandenen Findings.
- Setze in der Meta-Zeile das aktuelle Datum und den aktuellen Branch ein.

## Schritt 3 — Keine Implementierungen

Nimm **keinerlei** Änderungen außerhalb von
`AGENT/project-health-report.html` vor:

- Keine Fixes, Refactorings oder neuen Features.
- Keine Formatierungs- oder sonstigen Änderungen an anderen Dateien.

## Schritt 4 — Commit

Erstelle einen Commit, der **nur** `AGENT/project-health-report.html` enthält,
mit einer aussagekräftigen Commit-Message (z. B. Was hinzugekommen/entfernt wurde).
Committe **auf dem aktuellen Branch** — lege **nicht** ungefragt einen neuen Branch
an (außer der User bittet ausdrücklich darum).
