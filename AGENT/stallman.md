# Was Richard Stallman zu diesem Repository sagen würde

Ein (halb ernst gemeinter) Freie-Software-Review dieses Dotfiles-Repos aus der
Perspektive von RMS. Grundlage: der tatsächliche Zustand von `config/`, `setup/`
und `README.md` am 2026-07-15. Reihenfolge grob nach Stallmans Empörungspegel.

> „I'd be glad to help, but first: it's **GNU/Linux**."

---

## 1. Claude / Claude Code — SaaSS, das Kardinalproblem

**Was ihn stört:** Das Repo pflegt ein `config/claude/`-Verzeichnis und ist von
einem KI-Agenten mitverwaltet. Für Stallman ist das ein Paradebeispiel für
**SaaSS** (*Service as a Software Substitute*): Die eigentliche Rechenarbeit läuft
auf Anthropics Servern, der Code ist proprietär, und die Eingaben verlassen den
Rechner. „Du hast die Kontrolle über dein Computing an einen Server abgegeben, den
du weder besitzt noch inspizieren kannst." Zusätzlich: die verarbeiteten Daten
(deine Configs, dein Verhalten) liegen bei einem Dritten.

**Wie man es ändert:** Lokale, freie Modelle statt eines Cloud-Dienstes — z. B.
`llama.cpp`/`llamafile` mit einem Modell unter freier Lizenz, offline betrieben.
Wenn ein Agent bleibt, dann einer, dessen Client **und** Inferenz frei und lokal
sind. Minimalkompromiss: klar dokumentieren, welche Daten das Gerät verlassen, und
`config/claude/` nicht als „Config wie jede andere" behandeln.

## 2. GitHub — der proprietäre Wirt

**Was ihn stört:** Das Repo lebt mit `.github/workflows/`, dem `gh`-CLI und
„commits and pushes it on login" sichtbar auf GitHub. Stallman lehnt GitHub seit
Jahren ab: nicht-freies JavaScript im Browser, proprietäre Plattform, Microsoft-
Eigentum. Ausgerechnet ein *Freiheits*-Setup an den unfreisten Forge zu hängen,
wäre für ihn die eigentliche Ironie.

**Wie man es ändert:** Nach **Codeberg** (Forgejo, AGPL), zu einer selbst
gehosteten **Forgejo/GitLab-CE**-Instanz oder auf **Savannah** (GNU) umziehen. Die
CI (`validate.yml`, Selftest) läuft 1:1 unter Forgejo Actions. `gh` durch reines
`git` über SSH ersetzen.

## 3. Hotmail als Commit-Identität — Microsoft-Surveillance

**Was ihn stört:** `config/git/config` trägt
`email = leonhard-weiler@hotmail.com`. Jeder Commit ist damit signiert **und**
outet einen Microsoft-/Outlook-Account. Für Stallman ist eine proprietäre,
überwachte E-Mail-Plattform als kryptografisch bezeugte Identität ein
Selbstwiderspruch.

**Wie man es ändert:** Eine Adresse bei einem Anbieter, der keine Geiselnahme des
Postfachs betreibt — eigene Domain, ein GNU-freundlicher Host, oder mindestens ein
Anbieter ohne clientseitiges proprietäres JS-Erfordernis. Immerhin: die Commits
sind SSH-signiert, nicht mit einem proprietären Dienst — das würde er gutheißen.

## 4. Arch Linux statt eines FSF-gebilligten Systems

**Was ihn stört:** Das Setup ist explizit Arch. Arch steht **nicht** auf der
FSF-Liste freier Distributionen: Die Repos enthalten unfreie Software, es gibt
keine Richtlinie dagegen, und der Standardkernel zieht unfreie Firmware.

**Wie man es ändert:** **Parabola GNU/Linux-libre** — das ist praktisch Arch,
aber von unfreien Paketen und Blobs bereinigt, mit `pacman` und rollierend. Der
Umstieg wäre für dieses Repo minimal-invasiv, weil die ganze `pacman`-Maschinerie
identisch bleibt. Alternativ **Trisquel** (auf Ubuntu-Basis) oder **Guix System**.

## 5. `linux-firmware` + Stock-Kernel — unfreie Blobs

**Was ihn stört:** `programs.txt` listet `linux-firmware` und den generischen
`linux`-Kernel. `linux-firmware` ist ein Sammelbecken proprietärer Binär-Blobs;
der Stock-Kernel lädt sie klaglos. Für Stallman läuft damit auf dem Gerät
nicht-freie Software, die niemand auditieren kann. (`amd-ucode` ist Microcode —
denselben Vorbehalt hat er auch hier, betrachtet es aber pragmatisch als vom
Prozessor untrennbar.)

**Wie man es ändert:** `linux` durch **`linux-libre`** ersetzen und
`linux-firmware` durch **`linux-libre-firmware`** (nur die frei lizenzierten
Blobs). Konsequenz: Hardware, die zwingend unfreie Firmware braucht (manche WLAN-/
GPU-Chips), funktioniert dann evtl. nicht — für RMS ein Grund, freiheits­taugliche
Hardware zu kaufen, kein Grund für den Blob.

## 6. `yay` und der AUR — Tor zu unfreier Software

**Was ihn stört:** `setup/install-programs` bootstrappt `yay` und installiert aus
dem AUR. Der AUR macht keinerlei Freiheits-Unterscheidung; ein einziges
`yay -S <proprietär>` unterläuft das ganze Prinzip. Der Mechanismus selbst ist
das Problem, nicht (nur) die heute installierten Pakete.

**Wie man es ändert:** Unter Parabola entfällt der AUR-Bedarf weitgehend; wo doch
gebaut wird, `libre`-Repos bevorzugen. Zumindest in `programs.txt`/`README.md`
dokumentieren, welche Pakete frei sind, und AUR-Installationen auf frei lizenzierte
`PKGBUILD`s beschränken.

## 7. „Linux" statt „GNU/Linux" — die Namensfrage

**Was ihn stört:** `README.md` schreibt durchgängig „Arch Linux", `CLAUDE.md`
erwähnt „GNU" **null Mal** (`grep -c GNU CLAUDE.md` = 0). Das System ist das
GNU-Betriebssystem mit dem Kernel Linux; der verkürzte Name verschweigt für
Stallman das ganze GNU-Projekt und damit die Freiheitsgeschichte dahinter.

**Wie man es ändert:** In Prosa (README, CLAUDE.md) konsequent **„GNU/Linux"**
schreiben, wo das ganze System gemeint ist; „Linux" nur für den Kernel.

## 8. GPLv3 ist da — aber nicht angewandt

**Was ihn *freut*:** Es liegt eine **`LICENSE` mit GPLv3** im Root. Freie Lizenz,
Copyleft, seine eigene — das ist genau richtig und der stärkste Punkt des Repos.

**Was ihn trotzdem stört:** Die Lizenz steht nur herum. Die Skripte
(`install`, `config/usrbin/*`, die `#!/bin/sh`-Tools) tragen **keine
Lizenz-/Copyright-Header**. Ohne Header ist bei einer einzeln kopierten Datei die
Lizenz nicht mitgereist.

**Wie man es ändert:** Kurzen GPLv3-Header + Copyright-Zeile in jedes Skript
setzen (der Standardblock „This program is free software: you can redistribute
it…"). Optional maschinenlesbar via **REUSE**/SPDX
(`# SPDX-License-Identifier: GPL-3.0-or-later`).

## 9. Randnotizen (leiseres Stirnrunzeln)

- **KeePassXC** (`config/keepassxc/`): freie Software, GPL — **Daumen hoch**. Dass
  die `*.kdbx` nicht eingecheckt wird, ist genau die richtige Trennung.
- **Wayland/Hyprland, Alacritty, btop, mpv, rofi, mako, nvim**: alles frei
  lizenziert — hier hat er nichts zu meckern.
- **Noto-Fonts, JetBrains-Mono-Nerd**: frei lizenziert — passt.
- **systemd**: frei, aber Stallman hat es historisch für seinen monolithischen
  Zuschnitt kritisiert. Kein Freiheits-Problem, nur ein philosophisches Naserümpfen.
- **`WLR_DRM_DEVICES`-Pin** auf `pci-…-card` (`config/hypr/env.lua`): Da das Gerät
  `amd-ucode` fährt, ist es eine AMD-GPU mit freiem Treiber — **kein NVIDIA-Blob**,
  gut so.

---

## Prioritätenliste (wenn RMS nur drei Wünsche hätte)

1. **Claude/SaaSS** ersetzen oder klar eingrenzen (§1) — das größte Freiheitsleck.
2. Weg von **GitHub** hin zu Forgejo/Codeberg (§2).
3. Auf **Parabola GNU/Linux-libre** mit `linux-libre` umsteigen (§4/§5).

> „With free software, you control the program. With this repo, mostly *something*
> controls you — let's flip the last few of those."
