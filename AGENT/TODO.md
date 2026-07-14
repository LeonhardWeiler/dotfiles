1. „Linux" statt „GNU/Linux" — die Namensfrage

**Was ihn stört:** `README.md` schreibt durchgängig „Arch Linux", `CLAUDE.md`
erwähnt „GNU" **null Mal** (`grep -c GNU CLAUDE.md` = 0). Das System ist das
GNU-Betriebssystem mit dem Kernel Linux; der verkürzte Name verschweigt für
Stallman das ganze GNU-Projekt und damit die Freiheitsgeschichte dahinter.

**Wie man es ändert:** In Prosa (README, CLAUDE.md) konsequent **„GNU/Linux"**
schreiben, wo das ganze System gemeint ist; „Linux" nur für den Kernel.

2. GPLv3 ist da — aber nicht angewandt

**Was ihn _freut_:** Es liegt eine **`LICENSE` mit GPLv3** im Root. Freie Lizenz,
Copyleft, seine eigene — das ist genau richtig und der stärkste Punkt des Repos.

**Was ihn trotzdem stört:** Die Lizenz steht nur herum. Die Skripte
(`install`, `config/usrbin/*`, die `#!/bin/sh`-Tools) tragen **keine
Lizenz-/Copyright-Header**. Ohne Header ist bei einer einzeln kopierten Datei die
Lizenz nicht mitgereist.

**Wie man es ändert:** Kurzen GPLv3-Header + Copyright-Zeile in jedes Skript
setzen (der Standardblock „This program is free software: you can redistribute
it…"). Optional maschinenlesbar via **REUSE**/SPDX
(`# SPDX-License-Identifier: GPL-3.0-or-later`).

? Frage: Muss ich wirklich bei JEDER Datei das machen, das sind hier schon echt viele (129 glaub ich)

3. Too many moving parts pretending to be minimal

**The gripe:** The README says "dependency-free" and "minimal," then `install`
is **870 lines of Bash** with a step registry, a state-file snapshot system,
glob expansion, a validation pipeline, self-tests, and a scrub tri-state. Luke's
whole LARBS installer is a couple hundred lines of POSIX `sh` and a CSV. He'd
say you rebuilt dotbot to avoid dotbot.

**How to appease him:** Either own that it's a real program (fine!) or actually
cut it. The `--remove-programs`, `--remove-systemd`, `clean`, `prune`, and
`selftest` machinery is a lot of surface for one user's laptop. Ask per feature:
"have I used this in six months?" If no, `git rm` the branch of logic. Minimal
is a subtraction discipline, not a marketing word in the README.

4. The bash-only holdouts

**The gripe:** Most scripts are honest `#!/bin/sh` — good. But `install` and
`config/usrbin/update_programs_list` are `#!/bin/bash` for associative arrays
and process substitution. Luke's position: if you need associative arrays in a
shell script, the script wants to be smaller, not fancier.

**How to appease him:** Not worth a rewrite for its own sake, but every time you
reach for a bashism, treat it as a smell that the function is doing too much.
The `usrbin/*` scripts are already POSIX and that's the standard to hold the
rest to.

5. systemd, systemd everywhere

**The gripe:** This is the big one. Luke daily-drove **Artix** (Arch minus
systemd) specifically to get away from this. `setup/services.txt` enables a dozen
units, there's a `logind.conf`, `systemd-system/` and `systemd-user/` config
trees, a `dotfiles-sync.service`, a `battery-check.timer`... He'd call it "init
system as a lifestyle."

**How to appease him:** You're on Arch and systemd is the reality — no runit
crusade required. But `dotfiles-sync.service` and `battery-check.timer` are
things a **cron line or a plain shell loop** could do without a unit file, a
`.timer`, and a linked symlink each. Where a one-liner works, prefer the
one-liner; reserve units for what genuinely needs socket activation or ordering.

6. Remove rofi_keepassxc script, not necessary anymore
