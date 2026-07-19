# What Would Luke Smith Say?

A tongue-in-cheek code review of this repo through the eyes of Luke Smith —
suckless disciple, systemd hater, POSIX purist, sworn enemy of bloat. Each
gripe is real (he's actually said versions of all of these) and paired with
what it would take to make him stop scowling. You don't have to agree with any
of it — that's the point.

---

## 1. "Wayland? Hyprland?? What is this, a rice for reddit?"

**The gripe:** Luke ran X11 with dwm and swore Wayland was a solution in search
of a problem for the better part of a decade. A tiling _compositor_ written in
C++ with an animation engine and a **Lua** config file is peak "ricing over
computing." Animations on window open? Blur? He'd close the tab.

**How to appease him:** You won't switch off Hyprland and you shouldn't. But
`config/hypr/animations.lua` and the blur/rounding in `looknfeel.lua` are the
parts he'd actually call bloat. A documented "minimal mode" (animations off,
no blur, no rounding) would be the honest suckless gesture — and genuinely
useful on the battery-powered Legion this repo targets.

## 2. Too many moving parts pretending to be minimal

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

## 3. The bash-only holdouts

**The gripe:** Most scripts are honest `#!/bin/sh` — good. But `install` and
`config/usrbin/update_programs_list` are `#!/bin/bash` for associative arrays
and process substitution. Luke's position: if you need associative arrays in a
shell script, the script wants to be smaller, not fancier.

**How to appease him:** Not worth a rewrite for its own sake, but every time you
reach for a bashism, treat it as a smell that the function is doing too much.
The `usrbin/*` scripts are already POSIX and that's the standard to hold the
rest to.

## 4. systemd, systemd everywhere

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

## 5. GUI everything: keepassxc, qt5ct, rofi, mako

**The gripe:** `rofi_keepassxc` is **201 lines** to put a password manager behind
a graphical menu. Luke keeps passwords in **pass** (`pass`, gpg-encrypted files,
tab-completes in the shell) and picks them with `dmenu` in about ten lines. A Qt
theming config (`qt5ct`) exists purely to make GUI toolkits look consistent — a
problem he sidesteps by not running Qt apps.

**How to appease him:** Nothing's broken here. But `rofi_keepassxc` at 201 lines
is the single most "over-built for the job" script in `usrbin/` — worth a read to
see if half of it is error-handling for cases that can't happen. Shorter is
suckless-er.

## 6. Where's the email? Where's the RSS?

**The gripe:** Luke's whole brand is doing _real work_ in the terminal — email
in **neomutt**, RSS in **newsboat**, files in **lf**, notes in vim. This repo has
theming, compositor eye-candy, and a wallpaper randomizer, but no config for a
single terminal-productivity tool of that kind. He'd say you configured the paint
and forgot the house.

**How to appease him:** This is the most _constructive_ item. If you live in the
browser for mail/feeds/files, a terminal newsboat or lf setup is a genuinely nice
addition that fits the repo's ethos far better than another blur radius. Not a
criticism of what's here — a suggestion of what's missing.

## 7. The wallpaper randomizer

**The gripe:** `config/wallpaper/change-wallpaper.sh` + a `pictures/` set +
wbg, wired into autostart. To Luke this is the _definition_ of ricing —
effort spent on how the desktop looks while idle. "Nobody sees your wallpaper;
you have windows open."

**How to appease him:** Keep it — it's ten lines and harmless. But it's the
perfect example to point at when deciding whether the _next_ feature is computing
or decorating. Ship things that do work; be honest that this one is for fun.

---

## The verdict he'd actually give

He'd grumble through all of the above, then admit the parts that matter are
right: **plain-text configs in git, POSIX `sh` for most scripts, an explicit
`links.conf` instead of magic, no Python/dotbot dependency, a package manifest as
the single source of truth.** That's genuinely suckless-adjacent and better than
99% of the `~/.dotfiles` repos on his subreddit.

The one-line summary: _"Rip out half the installer, question every systemd unit
and every animation, and put a newsboat config where the wallpaper script is."_
Take the half of that you agree with.
