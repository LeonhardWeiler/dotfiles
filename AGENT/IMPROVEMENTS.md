# Improvements — backlog

A cleaned-up, checkable list of possible improvements for the `./install` tooling
and the repo, distilled from a longer design review. Nothing here is required;
work through it in whatever order you like. Ordering follows the review's own
priority: **validation → maintainability → testing → features → portability**.

Effort tags: `[S]` small · `[M]` medium · `[L]` large.

---

## 1 · Validation & strict parsing (highest priority)

The parser currently warns and continues on bad input. The review's main
recommendation is to fail early and never do a partial install.

- [ ] `[M]` Add `./install validate` — a filesystem-free check that runs before
      any action (and in CI). It should verify: syntax, unique targets, unique
      sources, source exists, source inside the repo, valid target, no duplicate
      entries, all globs matched, no absolute sources, no empty/tab garbage, no
      trailing junk.
- [ ] `[S]` Make a malformed `links.conf` **fatal** (error with `links.conf:<line>`
      and abort) instead of `warn` + `continue`.
- [ ] `[S]` Detect duplicate **targets** and duplicate **sources** (associative
      arrays); abort on collision instead of silently letting the last one win.
- [ ] `[M]` Reject sources that escape the repo (`realpath` vs `$BASEDIR`), e.g.
      `../../etc/passwd`.
- [ ] `[S]` Restrict target prefixes: allow `~` and `/etc`; reject `/tmp`, `/usr`,
      … unless explicitly opted in.
- [ ] `[S]` Make an unmatched glob source fatal, unless the entry is explicitly
      marked optional.
- [ ] `[M]` Split the run into clear phases: **parse → validate → expand globs →
      build table → execute**, so execution never sees a malformed entry.

## 2 · Maintainability & structure

`install` is ~700 lines in one file — the point where splitting starts to pay off.

- [ ] `[L]` Split `install` into sourced modules and keep `install` as a thin
      (~120-line) entry point. Suggested layout:
      `setup/{parser,links,steps,systemd,output,validate}.sh`, sourced at the top;
      `install` mostly does `parse_args → load_links → case "$CMD" in …`.
- [ ] `[M]` Introduce `prepare_target()` returning source/target/root, to remove
      the duplicated `expand_target` + `needs_root` logic in
      `link_one`/`unlink_one`/`status_one`/`clean_one`.

## 3 · Data / code separation

Push the last hardcoded lists out of the script so the installer is fully generic.

- [ ] `[S]` Move `SYSTEM_UNITS` / `USER_UNITS` into a data file (e.g.
      `setup/services.txt`).
- [ ] `[S]` Move `GROUP_LIST` into `setup/groups.txt`.
- [ ] `[S]` Move `FONT_PACKAGES` into a data file (e.g. `setup/fonts.txt`).

## 4 · Testing

- [ ] `[M]` Add a hidden `./install selftest`: create a temporary `HOME`
      (`mktemp -d`), run the installer against it, verify the links, clean up.
      Lets you test almost everything without a VM.
- [ ] `[S]` Wire `validate` (and later `selftest`) into CI so every push is checked.

## 5 · Selective install (nice for daily use & testing)

- [ ] `[M]` Add `--only <name>` / `--exclude <name>` to link just a subset of
      configs.
- [ ] `[M]` Alternatively, a `setup/profile.conf` with `disable=mpv` /
      `disable=typst` lines that the installer skips.

## 6 · UX / output polish

- [ ] `[S]` Extend the `info`/`warn`/`ok` helpers with clearer glyphs
      (`ℹ` / `✔` / `!`) and tidier prompts. (Already partly done.)

## 7 · Multi-distro portability (large, optional — only if the repo should be
more than "my Arch setup")

Keep the current simplicity; add a thin backend layer instead of scattering
`case "$ID"` checks. Each backend implements the same small function set:
`install_packages`, `remove_packages`, `enable_service`, `disable_service`,
`rebuild_initramfs`, `refresh_font_cache`.

- [ ] `[L]` Add `backends/{arch,fedora,void,artix}.sh`; `source backends/$DISTRO.sh`
      at startup so `install` never mentions `pacman`/`yay`/`dnf`/`xbps`/`systemctl`.
- [ ] `[S]` Detect the distro via `/etc/os-release` (`$ID`) and the init system via
      `readlink /proc/1/exe` (systemd / runit / openrc / dinit / s6).
- [ ] `[M]` Per-distro package manifests: `setup/packages/{arch,fedora,void,artix}.txt`
      (+ a shared `common.txt`), since package names differ
      (`ttf-jetbrains-mono-nerd` vs `jetbrains-mono-fonts`, etc.).
- [ ] `[M]` Per-init service lists: `setup/services/{systemd,runit,openrc}.txt`.
- [ ] `[S]` Abstract fonts per distro (`noto-fonts` vs `google-noto-sans-fonts`).

---

## Decisions already made (context, not TODO)

- **Keep Bash for `install`.** For a Linux dotfiles orchestrator (symlinks +
  `systemctl`/`pacman`/`locale-gen`/`mkinitcpio`), Bash is the natural choice;
  rewriting in Python would just wrap `subprocess.run([...])`. Don't rewrite it.
- **Don't force full POSIX on `install`.** The project is intentionally
  Arch + systemd + Hyprland. Lean into Bash instead (associative arrays,
  `mapfile`, `printf -v`, `declare -n` namerefs) and document *"requires Bash ≥ 5.0"*.
  The small helper scripts are already POSIX `#!/bin/sh`; only `install` and
  `update_programs_list` stay Bash on purpose.
- **No CLI framework** (bashly / bash3boilerplate). The current CLI is clean and
  the "dependency-free" property is worth keeping. `gum` gives nice TUI prompts
  but adds a dependency — not worth it here.

## Already good (keep as-is)

Data-driven `links.conf`, idempotent re-runs, `--force` → `.bak` backups,
`status`, `-n/--dry-run`, and the `register_step` registry are all called out as
strengths in the review. No change needed.
