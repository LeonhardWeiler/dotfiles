Ich verwende Arch Linux mit Hyprland und möchte eine robuste Workspace-Automatisierung erstellen.

## Ziel

Schreibe Bash-Skripte für mein bestehendes Setup. Alle Skripte liegen in:

```bash
~/.config/scripts/
```

Bitte implementiere die Lösung **schrittweise**.

---

# Schritt 1: Analyse

Bevor du Code schreibst:

* Erstelle einen vollständigen Plan.
* Beschreibe die Architektur.
* Erkläre, welche Informationen du noch benötigst.
* Stelle Rückfragen, wenn etwas unklar ist.
* Schreibe erst Code, nachdem alle offenen Fragen geklärt wurden.

---

# Schritt 2: Workspace Manager

Ich möchte zunächst ein neues Rofi-Manager-Skript erstellen.

Bitte sieh dir zuerst meine vorhandenen Rofi-Skripte in

```bash
~/.config/scripts/
```

an und orientiere dich an deren Struktur und Stil.

Der neue Manager soll später verschiedene Workspace-Konfigurationen starten können.

Zunächst soll es genau einen Eintrag geben:

* `slf-workspace`

Wenn ich diesen auswähle, soll automatisch mein kompletter AI-Workspace hergestellt werden.

Dieses Manager-Skript soll anschließend über den Hyprland-Shortcut

```
SUPER + W
```

gestartet werden.

---

# Verhalten des Workspace-Managers

Das Ziel ist **kein blindes Neustarten aller Programme**, sondern das Herstellen eines definierten Zustands.

Für jede benötigte Anwendung gilt:

* Wenn sie bereits läuft:

  * nicht neu starten
  * in den richtigen Workspace verschieben
  * richtig anordnen
  * ggf. in den richtigen Ordner wechseln bzw. den richtigen Prozess starten

* Wenn sie noch nicht läuft:

  * starten
  * korrekt konfigurieren
  * an die richtige Position verschieben

Programme, die **nicht** Teil dieser Workspace-Konfiguration sind (z. B. KeePassXC), sollen geschlossen werden.

Die Workspace-Konfiguration soll nach dem Ausführen immer denselben Endzustand besitzen.

---

# Workspace 1

Linke Hälfte:

* `zen-browser-bin`

Rechte Hälfte:

* `alacritty`
* Arbeitsverzeichnis:

```bash
~/files/projects/slf/
```

* Dort soll mein Alias

```bash
c
```

ausgeführt werden.

Dieser startet Claude Code im Bypass-All-Modus.

---

# Workspace 2

Linke Hälfte:

Ein neuer Zen-Browser mit folgenden Tabs:

* Review-HTML-Datei `~/files/projects/slf/prompts/project-health-report.html`
* zweimal `http://localhost:5173` (im horizontalen split mode wenn möglich)

Rechte Hälfte (vertikal geteilt):

Oben:

* Projektordner

```bash
~/files/projects/slf/
```

* dort

```bash
nvim .
```

Unten:

* Alacritty
* Arbeitsverzeichnis

```bash
~/files/projects/slf/
```

---

# Workspace 3

Linke Hälfte:

Alacritty

Arbeitsverzeichnis:

```bash
~/files/projects/slf/
```

Dann automatisch:

```bash
nix develop
cd frontend
bun run dev
```

Rechte Hälfte:

Alacritty

Arbeitsverzeichnis:

```bash
~/files/projects/slf/
```

Dann:

```bash
nix develop
cd backend
air
```

---

# Umsetzung

Die Lösung soll möglichst robust sein.

Berücksichtige insbesondere:

* Hyprland IPC (`hyprctl`)
* Fenster anhand von Klasse oder Titel erkennen
* vorhandene Fenster wiederverwenden
* Workspaces automatisch erstellen
* Fenster korrekt verschieben
* Fenster korrekt aufteilen
* Race Conditions beim Start vermeiden
* auf gestartete Fenster warten
* sinnvolle Fehlerbehandlung
* möglichst idempotentes Verhalten

Bevor du irgendeinen Code schreibst, stelle alle notwendigen Rückfragen.

