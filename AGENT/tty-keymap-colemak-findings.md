# TTY-Keymap (colemak-dh) — Diagnose-Findings

**Datum:** 2026-07-05
**Symptom:** Im ly-Passwortfeld (und generell auf den Text-VTs) ist das
Tastaturlayout QWERTY statt des gewünschten Colemak-DH, obwohl die vconsole-Config
scheinbar korrekt ist.

## Kurzfazit

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
