# Was Richard Stallman zu diesem Repository sagen würde

Ein (halb ernst gemeinter) Freie-Software-Review dieses Dotfiles-Repos aus der
Perspektive von RMS. Grundlage: der tatsächliche Zustand von `config/`, `setup/`
und `README.md` am 2026-07-20. Reihenfolge grob nach Stallmans Empörungspegel.

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
`config/claude/` nicht als „Config wie jede andere" behandeln. Immerhin: das
`config/claude/`-Linking trackt bewusst **keine** `.claude.json`/Sessions/History/
Secrets — die richtige Trennung, so weit sie hier geht.

## 2. GitHub — der proprietäre Wirt

**Was ihn stört:** Das Repo lebt weiterhin auf **GitHub** (`README.md`:
`git clone https://github.com/leonhardweiler/dotfiles.git`). Stallman lehnt GitHub
seit Jahren ab: nicht-freies JavaScript im Browser, proprietäre Plattform,
Microsoft-Eigentum. Ausgerechnet ein *Freiheits*-Setup an den unfreisten Forge zu
hängen, wäre für ihn die eigentliche Ironie.

**Was sich entspannt hat:** Es gibt **kein `.github/workflows/` mehr** (keine
proprietär gehostete CI), und der frühere „commit-and-push-on-login"-Automatismus
inklusive `gh`-CLI ist **entfernt** (`dotfiles_sync`-Skript gelöscht). Damit hängt
nur noch der *Hosting-Ort* an GitHub, nicht mehr eine Automatik darum herum.

**Wie man es ändert:** Nach **Codeberg** (Forgejo, AGPL), zu einer selbst
gehosteten **Forgejo/GitLab-CE**-Instanz oder auf **Savannah** (GNU) umziehen.
Reines `git` über SSH statt `gh` — das ist ohnehin schon der Zustand.

## 3. Hotmail als Commit-Identität — Microsoft-Surveillance

**Was ihn stört:** `config/git/config` trägt
`email = leonhard-weiler@hotmail.com`. Jeder Commit ist damit signiert **und**
outet einen Microsoft-/Outlook-Account. Für Stallman ist eine proprietäre,
überwachte E-Mail-Plattform als kryptografisch bezeugte Identität ein
Selbstwiderspruch.

**Wie man es ändert:** Eine Adresse bei einem Anbieter, der keine Geiselnahme des
Postfachs betreibt — eigene Domain, ein GNU-freundlicher Host, oder mindestens ein
Anbieter ohne clientseitiges proprietäres JS-Erfordernis. Immerhin: die Commits
sind SSH-signiert, nicht über einen proprietären Dienst — das würde er gutheißen.

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

**Was ihn versöhnlicher stimmt:** Die `README.md` benennt das inzwischen **selbst
und ehrlich** — in der Sektion *„Non-free packages"* steht wortwörtlich, dass
`linux-firmware`/`amd-ucode` non-free Blobs mitbringen und man für ein voll freies
System `linux`/`linux-firmware` gegen **`linux-libre`/`linux-libre-firmware`**
tauschen soll. Genau seine Empfehlung, im Repo dokumentiert. Die Doku ist da — nur
die Praxis fehlt noch.

**Wie man es ändert:** Der Anleitung im eigenen README folgen: `linux` durch
**`linux-libre`** ersetzen und `linux-firmware` durch **`linux-libre-firmware`**.
Konsequenz: Hardware, die zwingend unfreie Firmware braucht, funktioniert dann
evtl. nicht — für RMS ein Grund, freiheitstaugliche Hardware zu kaufen, kein Grund
für den Blob.

## 6. `yay` und der AUR — Tor zu unfreier Software

**Was ihn stört:** `setup/install-programs` bootstrappt `yay` und installiert aus
dem AUR. Der AUR macht keinerlei Freiheits-Unterscheidung; ein einziges
`yay -S <proprietär>` unterläuft das ganze Prinzip. Und die `programs.txt` macht
davon Gebrauch: `unityhub`, `plasticscm-client-gui`, `figma-agent-linux-bin`,
`dotnet-sdk`, `signal-desktop`, `zen-browser-bin` — für Stallman lauter unfreie
oder halb-unfreie Software.

**Was ihn versöhnlicher stimmt:** Die `README.md`-Sektion *„Non-free packages"*
zählt die proprietären Pakete **namentlich und offen** auf („In the interest of
honesty…"). Das ist nicht Freiheit, aber es ist die Ehrlichkeit, die er verlangt:
kein Verstecken hinter dem Wort „minimal".

**Wie man es ändert:** Unter Parabola entfällt der AUR-Bedarf weitgehend; wo doch
gebaut wird, `libre`-Repos bevorzugen und AUR-Installationen auf frei lizenzierte
`PKGBUILD`s beschränken.

## 7. „Linux" statt „GNU/Linux" — die Namensfrage (weitgehend erledigt)

**Was ihn *früher* störte:** Das README schrieb durchgängig „Arch Linux".

**Was jetzt gilt:** `README.md` schreibt konsequent **„GNU/Linux"** bzw. **„Arch
GNU/Linux"** (`grep -c GNU README.md` = 4), und `CLAUDE.md` nennt „GNU/Linux"
ebenfalls. Genau die Korrektur, auf die er seit Jahrzehnten pocht — hier
umgesetzt. Einziger Rest: in Fließtext den Kernel weiterhin nur dann „Linux"
nennen, wenn wirklich der Kernel gemeint ist. Ansonsten: **Daumen hoch.**

## 8. Von GPLv3 zu ISC — der Rückschritt beim Copyleft

**Was ihn *früher* freute:** Es lag eine `LICENSE` mit **GPLv3** im Root — freie
Lizenz, Copyleft, seine eigene. Das war der stärkste Punkt des Repos.

**Was jetzt gilt — und ihn stört:** Die Lizenz ist auf **ISC** gewechselt
(`LICENSE`: „ISC License … The leonhardweiler/dotfiles Authors"). ISC ist zwar
eine *freie* Lizenz — daran ist nichts auszusetzen — aber eine **lasche,
permissive** ohne Copyleft. Für Stallman heißt das: jeder darf den Code nehmen,
proprietär einbetten und die Freiheit den Nutzern *entziehen*. Der Wechsel weg von
der GPL ist aus seiner Sicht ein **Rückschritt** — er würde nachdrücklich zurück
zu **GPLv3-or-later** raten, um das Copyleft zu behalten.

**Was ihn dabei versöhnt:** Jedes Skript trägt jetzt einen maschinenlesbaren
**SPDX-Header** (`# SPDX-License-Identifier: ISC`) plus Copyright-Zeile —
`install`, `setup/install-programs`, alle `config/usrbin/*`. Die *Praxis* der
Header ist genau richtig (REUSE-konform); nur die *gewählte Lizenz* würde er
gerne wieder auf GPLv3 sehen.

## 9. Randnotizen (leiseres Stirnrunzeln)

- **dwl** statt Hyprland (`config/dwl/`): freie Software (MIT), ein schlankes
  wlroots-Projekt — **Daumen hoch**, freiheitlich wie funktional unbedenklich.
- **KeePassXC** (`config/keepassxc/`): freie Software, GPL — **Daumen hoch**. Dass
  die `*.kdbx` nicht eingecheckt wird, ist genau die richtige Trennung.
- **Wayland/dwl, foot, btop, mpv, rofi, wob, nvim, hyprlock**: alles frei
  lizenziert — hier hat er nichts zu meckern.
- **Noto-Fonts, JetBrains-Mono-Nerd**: frei lizenziert — passt.
- **systemd**: frei, aber Stallman hat es historisch für seinen monolithischen
  Zuschnitt kritisiert. Kein Freiheits-Problem, nur ein philosophisches Naserümpfen.
- **AMD-GPU mit freiem Treiber** (`amd-ucode`, `vulkan-radeon`, `mesa`): **kein
  NVIDIA-Blob** für den Grafikstack — gut so.

---

## Prioritätenliste (wenn RMS nur drei Wünsche hätte)

1. **Claude/SaaSS** ersetzen oder klar eingrenzen (§1) — das größte Freiheitsleck.
2. Die Lizenz **zurück auf GPLv3** drehen, um das Copyleft zu retten (§8).
3. Auf **Parabola GNU/Linux-libre** mit `linux-libre` umsteigen (§4/§5) —
   die README beschreibt den Weg bereits selbst.

> „With free software, you control the program. This repo now names its non-free
> corners honestly and says GNU/Linux — good. Put the copyleft back, and flip the
> last few servers into your own hands."
