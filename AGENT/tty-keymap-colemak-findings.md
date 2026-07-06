# TTY-Keymap (colemak-dh) — Diagnose-Findings

**Datum:** 2026-07-05 · **GELÖST:** 2026-07-06
**Symptom:** Im ly-Passwortfeld (und generell auf den Text-VTs) ist das
Tastaturlayout QWERTY statt des gewünschten Colemak-DH, obwohl die vconsole-Config
scheinbar korrekt ist.

## Auflösung (2026-07-06)

**Ursache gefunden, Fix umgesetzt.** Der Reboot-Test (siehe unten) fiel klar auf
**„weiterhin qwerty"** aus: frischer Boot (17:28), niemand hatte `loadkeys`
ausgeführt, echte VT-Messung `18=e 19=r 20=t` → **us**. Im Boot-Log erste
**fehlgeschlagene** ly-Auth bei 49 s — das Passwort wurde mit falschem Layout
getippt.

**Root Cause — KMS/vconsole-setup-Race:** `systemd-vconsole-setup` läuft beim
Boot bei **28.5 s** (`ExecMainExit` 28515225 µs) und loggt *„Configuration of
first virtual console was skipped, ignoring remaining ones."* In systemd 261
kommt diese Meldung aus der Kette *„not in K_XLATE or K_UNICODE"* / *„not in
KD_TEXT"*: der initramfs-`kms`-Hook macht in diesem Moment gerade den Modeset,
die VT ist noch nicht in `KD_TEXT`/`K_XLATE`, also **überspringt vconsole-setup
das Keymap-Setzen komplett** — und der Modeset resettet zusätzlich die im
initramfs geladene Keymap auf den Kernel-Default `us`. Der *manuelle*
`restart systemd-vconsole-setup` (Finding unten) funktionierte nur, weil der
Modeset da längst fertig war. Damit ist die scheinbar widersprüchliche Diagnose
aufgelöst: vconsole-setup setzt die Keymap **nicht** beim Boot, sondern skippt.
ly (Start ~29.6 s) fasst die Keymap nicht an (bestätigt: keine keymap-Strings im
`ly-dm`-Binary) und spiegelt nur den globalen `us`-Zustand.

**Fix:** Drop-in `config/systemd-system/ly@tty2.service.d/keymap.conf` mit
`ExecStartPre=/usr/bin/loadkeys mod-dh-iso-uk` — lädt die Keymap unmittelbar vor
`ly-dm` (nach dem Modeset) neu. Wie `wait-home.conf` als **reale Kopie** nach
`/etc/systemd/system/ly@tty2.service.d/` deployt (kein `links.conf`-Symlink, da
`/home` beim frühen systemd-Start noch nicht gemountet ist). Deploy-Schritt jetzt
im README unter »Manual system state«. Verifiziert: `systemctl show ly@tty2 -p
ExecStartPre` zeigt das Kommando; endgültige Bestätigung beim nächsten Reboot
(ins ly-Feld tippen: `f p b` auf physisch `e r t`).

Nebenbefund: Das ebenfalls im Repo liegende `wait-home.conf` war auf dieser
Maschine **gar nicht** nach `/etc` deployt — jetzt mit deployt.

---

## Kurzfazit (ursprüngliche Diagnose, 2026-07-05)

**Die Installation ist vollständig und korrekt — daran liegt es nicht.** Die
gesamte vconsole-Kette (Symlink, Config-Inhalt, initramfs, `systemd-vconsole-setup`)
funktioniert nachweislich. Das eigentliche Problem: Die globale Konsolen-Keymap
wird beim Boot korrekt auf `mod-dh-iso-uk` gesetzt, aber **während des Boot-/
ly-Login-Übergangs einmalig auf `us` zurückgesetzt**. Offen bleibt nur, *wer*
resettet (endgültige Klärung braucht einen sauberen Reboot-Test).

## Verifizierte Fakten (alle geprüft)

| Prüfung | Ergebnis |
|---|---|
| `/etc/vconsole.conf` → Repo-Symlink | ✅ korrekt verlinkt (`./install status` = ok) |
| Inhalt `KEYMAP=mod-dh-iso-uk` | ✅ korrekt, committet (`6997d4f`), kein offener Diff |
| initramfs `keymap.bin` (`/efi/initramfs-linux.img`) | ✅ **Hash-identisch** mit frisch kompiliertem `mod-dh-iso-uk` — initramfs ist aktuell, `mkinitcpio -P` würde nichts ändern |
| `keymap.utf8` = 0 Bytes | ✅ Absicht (nur UTF-8-Marker via `add_file /dev/null`, keine kaputte Datei) |
| initramfs `keymap`-Runtime-Hook | ✅ vorhanden, lädt `loadkmap </keymap.bin` |
| `systemd-vconsole-setup.service` | ✅ static + active |
| `getty@tty1` (`agetty --noreset --noclear`) | ✅ resettet keine Keymap |
| `/etc/ly/config.ini` u. übrige Links | ✅ alle ok |

## Zentrale Messungen

Wichtig: `dumpkeys` in der Agent-Shell ist **wertlos** (läuft in einer pts, kein
echtes VT → liefert immer die eingebaute us-Tabelle). Zuverlässig gemessen wurde
von einem freien, inaktiven VT via `sudo sh -c 'dumpkeys < /dev/tty12'`
(Konsolen-Keymap ist systemweit/global, ein VT genügt).

- **Referenz obere Reihe:** colemak-dh → `16=q 17=w 18=f 19=p 20=b`,
  us-qwerty → `16=q 17=w 18=e 19=r 20=t`.
- **Ausgangszustand (~6 min nach Boot, unberührt):** `18=e 19=r 20=t` → **us**.
- **Nach `sudo loadkeys mod-dh-iso-uk`:** `18=f 19=p 20=b` → **colemak-dh** ✅
  (Keymap-Datei funktioniert einwandfrei).
- **Entscheidungstest:** `loadkeys us` (→ us bestätigt) → dann *nur*
  `systemctl restart systemd-vconsole-setup` → `18=f 19=p 20=b` → **colemak** ✅
  ⇒ vconsole-setup setzt die Keymap wirksam, trotz Log "skipped".
- **Nach dem Setzen stabil:** Keymap blieb ohne weiteres Zutun colemak
  ⇒ **kein laufender/periodischer Reset**, der Reset ist einmalig im
  Boot-/Login-Fenster.

## Aufgeklärte Nebenspuren (Sackgassen)

- **`systemd-vconsole-setup` "Configuration of first virtual console was skipped":**
  Irreführend. Debug-Log zeigt
  `Executing "/usr/bin/loadkeys -q -C /dev/tty1 -u mod-dh-iso-uk"... '/usr/bin/loadkeys' succeeded.`
  Die "skipped"-Meldung betrifft den **Font**, nicht die Keymap. Die Keymap
  *wird* gesetzt. tty1 ist normaler Textmodus (agetty), kein KD_GRAPHICS-Problem.
- **initramfs veraltet?** Nein — `keymap.bin` ist Hash-identisch mit
  `mod-dh-iso-uk`. `mkinitcpio -P` ist nicht nötig.
- **ly als Config-Fehler?** Nein. ly 1.4.1 hat **keine** `xkb_*`/keymap-Option
  (weder in `config.ini.example` noch als String im Binary) und **keine**
  keymap-manipulierenden Strings. ly liest nur die vom Kernel bereits übersetzten
  Zeichen ⇒ es **spiegelt** die globale Konsolen-Keymap, verursacht sie nicht.
- **udev `90-vconsole.rules`** (`restart systemd-vconsole-setup` bei vtcon-add)
  und **getty** setzen jeweils *colemak* bzw. gar nichts — kein us-Reset dort.

## Zwei getrennte Tastatur-Systeme (Kontext)

- **Text-VT / ly** → `/etc/vconsole.conf` `KEYMAP` (via loadkeys/initramfs/vconsole-setup).
- **Hyprland/Wayland-Session** → XKB, gesetzt in
  `config/hypr/looknfeel.lua` (`kb_layout = "us"`, `kb_variant = "colemak_dh"`).
  Völlig unabhängig von der vconsole-Keymap.

## Offene Frage / nächster Schritt

**Wer resettet die globale Keymap im Boot-/Login-Fenster von colemak auf us?**
Nur per **sauberem Reboot** klärbar:

1. Rebooten.
2. **Im ly-Passwortfeld tippen, bevor** man sich einloggt (Test: liegen `f p b`
   auf den physischen `e r t`-Tasten?).

Ergebnis:
- **colemak** → gelöst; war ein Altlast-Zustand von vor dem letzten sauberen Boot.
- **weiterhin qwerty** → ly bzw. der VT-Handoff resettet aktiv. Fix-Optionen:
  - systemd-Drop-in, das die Keymap unmittelbar vor `ly@tty2` erneut lädt
    (`ExecStartPre=/usr/bin/loadkeys mod-dh-iso-uk`), sauber im Repo getrackt, **oder**
  - ly-Upgrade auf eine Version mit `xkb_variant`-Option.

## Sofort-Workaround (bis Reboot)

`sudo loadkeys mod-dh-iso-uk` — wurde in dieser Session bereits ausgeführt; die
globale Konsolen-Keymap (und damit das ly-Feld) ist aktuell colemak-dh.
