# What Would Luke Smith Say?

A tongue-in-cheek code review of this repo through the eyes of Luke Smith —
suckless disciple, systemd skeptic, POSIX purist, sworn enemy of bloat. Each
gripe is real (he's actually said versions of all of these) and paired with
what it would take to make him stop scowling. You don't have to agree with any
of it — that's the point. Reviewed against the repo as of 2026-07-20.

---

## 1. "Wayland? ...huh, okay, dwl. Fine."

**The old gripe is gone.** The last time this repo was reviewed it ran
**Hyprland** — C++, a Lua config file, animations, blur, rounded corners. That
was peak "ricing over computing" and Luke would have closed the tab. It's gone.
The compositor is now **dwl**: the suckless project's own Wayland compositor,
dwm's little sibling — plain C, ~2000 SLOC, configured through a compiled
**`config.h`** (`config/dwl/config.h`, 166 lines), no Lua VM, no animation
engine, no blur.

**Where he'd still needle you:** he'd rather you were on `dwm` + `st` under X11,
and he'll never love Wayland. But given that constraint, dwl is the single most
honest choice on the board — `config.h` + `make`, patches for gaps/autostart,
a binary installed to `/usr/local/bin`. That's the suckless workflow, not a
critique of it. He'd tip his hat and move on.

## 2. Still more moving parts than "minimal" wants — but you stopped saying "minimal"

**The gripe:** `install` is **619 lines** of Bash with a `register_step`
registry (associative arrays!), glob expansion, a parse→validate→build→execute
pipeline for `links.conf`. That's a real program, not a shell script.

**What changed in your favor:** the `--scrub`, `prune`, `STATE_FILE`, `clean`,
`selftest`, and `--remove-programs`/`--remove-systemd` machinery that used to
push it past 840 lines is **gone**. And crucially, the README no longer sells
this as "minimal" — it now says outright *"meant to be practical, not
minimalist."* Luke's whole objection was the mismatch between the marketing word
and the reality; you closed the gap by dropping the word, not by lying. He can
respect that.

**How to appease him further:** the step registry is still the fanciest thing in
here. Every time you reach for a Bash associative array, treat it as a hint the
function wants to be smaller. But this is a much smaller target than it was.

## 3. The bash-only holdouts

**The gripe:** most scripts are honest `#!/bin/sh` — good. But `install` and
`config/usrbin/update_programs_list` are `#!/bin/bash` for associative arrays
and process substitution. Luke's position: if you need associative arrays in a
shell script, the script wants to be smaller, not fancier.

**How to appease him:** not worth a rewrite for its own sake, but every bashism
is a smell that the function is doing too much. The `usrbin/*` scripts —
`bat_check`, `vol_ctl`, `bright_ctl`, `osd`, `restic-backup` — are already POSIX
`sh`, each doing one thing. That's the standard to hold the rest to.

## 4. systemd — but you moved the right things off it

**The gripe:** `setup/services.txt` still `enable`s a stack of system units, and
there's a `logind.conf` drop-in. Luke daily-drove **Artix** to get away from
exactly this, and he'd call the whole tree "init system as a lifestyle."

**Where you already listened:** the `dotfiles-sync.service` is **deleted**, and
the battery check is **not** a `.timer`/`.service` pair anymore — it's a plain
`while true; do bat_check; sleep 120; done` loop spawned from the dwl
`autostart[]` in `config.h`. That is *precisely* the "prefer the one-liner over
the unit" move he preaches. `services.txt` now only lists system units that
genuinely need to be enabled (NetworkManager, ly, sshd, libvirtd, iptables,
fstrim.timer…). Not much left for him to swing at.

## 5. GUI passwords — but the 201-line script is dead

**The gripe:** you still keep passwords in **keepassxc** (a Qt GUI + a `qt5ct`
theming config) rather than **pass** (gpg files, tab-completed in the shell,
picked with `dmenu` in ten lines).

**What changed:** the single most over-built thing in `usrbin/` — the 201-line
`rofi_keepassxc` menu wrapper — is **gone**. That was the script Luke would have
read aloud line by line. Its removal is the biggest "shorter is suckless-er" win
in the repo since the last review. keepassxc itself is a preference, not a bug;
he'd shrug and mention `pass` one more time.

## 6. Where's the email? Where's the RSS?

**The gripe:** Luke's whole brand is doing *real work* in the terminal — email
in **neomutt**, RSS in **newsboat**, files in **lf**, notes in vim. This repo
has a compositor, a terminal, an editor, and audio/brightness helpers, but no
config for a single terminal-productivity tool of that kind. Mail and feeds live
in `thunderbird` and `zen-browser`. He'd say you configured the tools and forgot
the workflow.

**How to appease him:** this is the most *constructive* item and the one thing
that hasn't moved. A terminal newsboat or lf setup fits the repo's ethos far
better than anything graphical. Not a criticism of what's here — a suggestion of
what's missing.

## 7. The wallpaper randomizer — you stood it down

**Old gripe:** `change-wallpaper.sh` + a `pictures/` set + wbg wired into
autostart. "Nobody sees your wallpaper; you have windows open."

**Status:** the whole wallpaper feature is **disabled** — the autostart line is
commented out in `config.h`, the two `links.conf` lines are commented out,
nothing is built or linked. The files stay in the repo so it can come back, but
right now nothing decorative runs. Luke would count that as a point scored.

---

## The verdict he'd actually give

Compared to the Hyprland-era review, this repo moved hard in his direction: **a
suckless compositor (dwl) via `config.h`, the wallpaper randomizer stood down,
`dotfiles-sync` deleted, the battery check demoted from a systemd timer to a
shell loop, the 201-line rofi/keepassxc wrapper removed, and the word "minimal"
replaced with an honest "practical."** Add that to what was already right —
plain-text configs in git, POSIX `sh` for the small tools, an explicit
`links.conf`, no Python/dotbot dependency — and this is genuinely
suckless-adjacent now.

The one-line summary: *"You actually did the WM homework — now put a newsboat
config where the wallpaper script used to be, and keep questioning every
associative array in `install`."* Take the half of that you agree with.
