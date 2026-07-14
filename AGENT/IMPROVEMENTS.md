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
  `mapfile`, `printf -v`, `declare -n` namerefs) and document _"requires Bash ≥ 5.0"_.
  The small helper scripts are already POSIX `#!/bin/sh`; only `install` and
  `update_programs_list` stay Bash on purpose.
- **No CLI framework** (bashly / bash3boilerplate). The current CLI is clean and
  the "dependency-free" property is worth keeping. `gum` gives nice TUI prompts
  but adds a dependency — not worth it here.

## Already good (keep as-is)

Data-driven `links.conf`, idempotent re-runs, `--force` → `.bak` backups,
`status`, `-n/--dry-run`, and the `register_step` registry are all called out as
strengths in the review. No change needed.

---

Is everything to this XDG Base Directory Specification? If not replace the text underneath with a list of things that arent already compliant and how to fix them

Jump to content
Freedesktop Logo
XDG Base Directory Specification
Show Contents: XDG Base Directory Specification
Top
XDG Base Directory Specification #
Authors:
Waldo Bastian <bastian@kde.org>
Allison Karlitskaya <desrt@desrt.ca>
Lennart Poettering <lennart@poettering.net>
Johannes Löthberg <johannes@kyriasis.com>

Publication Date: 08th May 2021, Version: Version 0.8

1 Introduction
2 Basics
3 Environment variables
4 Referencing this specification

1 Introduction #

Various specifications specify files and file formats. This specification defines where these files should be looked for by defining one or more base directories relative to which files should be located.
2 Basics #

The XDG Base Directory Specification is based on the following concepts:

    There is a single base directory relative to which user-specific data files should be written. This directory is defined by the environment variable $XDG_DATA_HOME.

    There is a single base directory relative to which user-specific configuration files should be written. This directory is defined by the environment variable $XDG_CONFIG_HOME.

    There is a single base directory relative to which user-specific state data should be written. This directory is defined by the environment variable $XDG_STATE_HOME.

    There is a single base directory relative to which user-specific executable files may be written.

    There is a set of preference ordered base directories relative to which data files should be searched. This set of directories is defined by the environment variable $XDG_DATA_DIRS.

    There is a set of preference ordered base directories relative to which configuration files should be searched. This set of directories is defined by the environment variable $XDG_CONFIG_DIRS.

    There is a single base directory relative to which user-specific non-essential (cached) data should be written. This directory is defined by the environment variable $XDG_CACHE_HOME.

    There is a single base directory relative to which user-specific runtime files and other file objects should be placed. This directory is defined by the environment variable $XDG_RUNTIME_DIR.

All paths set in these environment variables must be absolute. If an implementation encounters a relative path in any of these variables it should consider the path invalid and ignore it.
3 Environment variables #

$XDG_DATA_HOME defines the base directory relative to which user-specific data files should be stored. If $XDG_DATA_HOME is either not set or empty, a default equal to $HOME/.local/share should be used.

$XDG_CONFIG_HOME defines the base directory relative to which user-specific configuration files should be stored. If $XDG_CONFIG_HOME is either not set or empty, a default equal to $HOME/.config should be used.

$XDG_STATE_HOME defines the base directory relative to which user-specific state files should be stored. If $XDG_STATE_HOME is either not set or empty, a default equal to $HOME/.local/state should be used.

The $XDG_STATE_HOME contains state data that should persist between (application) restarts, but that is not important or portable enough to the user that it should be stored in $XDG_DATA_HOME. It may contain:

    actions history (logs, history, recently used files, …)

    current state of the application that can be reused on a restart (view, layout, open files, undo history, …)

User-specific executable files may be stored in $HOME/.local/bin. Distributions should ensure this directory shows up in the UNIX $PATH environment variable, at an appropriate place.

Since $HOME might be shared between systems of different architectures, installing compiled binaries to $HOME/.local/bin could cause problems when used on systems of differing architectures. This is often not a problem, but the fact that $HOME becomes partially architecture-specific if compiled binaries are placed in it should be kept in mind.

$XDG_DATA_DIRS defines the preference-ordered set of base directories to search for data files in addition to the $XDG_DATA_HOME base directory. The directories in $XDG_DATA_DIRS should be separated with the separator used for $PATH on the platform (typically this is a colon :).

If $XDG_DATA_DIRS is either not set or empty, a value equal to /usr/local/share/:/usr/share/ should be used.

$XDG_CONFIG_DIRS defines the preference-ordered set of base directories to search for configuration files in addition to the $XDG_CONFIG_HOME base directory. The directories in $XDG_CONFIG_DIRS should be separated with the separator used for $PATH on the platform (typically this is a colon :).

If $XDG_CONFIG_DIRS is either not set or empty, a value equal to /etc/xdg should be used.

The order of base directories denotes their importance; the first directory listed is the most important. When the same information is defined in multiple places the information defined relative to the more important base directory takes precedent. The base directory defined by $XDG_DATA_HOME is considered more important than any of the base directories defined by $XDG_DATA_DIRS. The base directory defined by $XDG_CONFIG_HOME is considered more important than any of the base directories defined by $XDG_CONFIG_DIRS.

$XDG_CACHE_HOME defines the base directory relative to which user-specific non-essential data files should be stored. If $XDG_CACHE_HOME is either not set or empty, a default equal to $HOME/.cache should be used.

$XDG_RUNTIME_DIR defines the base directory relative to which user-specific non-essential runtime files and other file objects (such as sockets, named pipes, ...) should be stored. The directory MUST be owned by the user, and they MUST be the only one having read and write access to it. Its Unix access mode MUST be 0700.

The lifetime of the directory MUST be bound to the user being logged in. It MUST be created when the user first logs in and if the user fully logs out the directory MUST be removed. If the user logs in more than once they should get pointed to the same directory, and it is mandatory that the directory continues to exist from their first login to their last logout on the system, and not removed in between. Files in the directory MUST not survive reboot or a full logout/login cycle.

The directory MUST be on a local file system and not shared with any other system. The directory MUST be fully-featured by the standards of the operating system. More specifically, on Unix-like operating systems AF_UNIX sockets, symbolic links, hard links, proper permissions, file locking, sparse files, memory mapping, file change notifications, a reliable hard link count must be supported, and no restrictions on the file name character set should be imposed. Files in this directory MAY be subjected to periodic clean-up. To ensure that your files are not removed, they should have their access time timestamp modified at least once every 6 hours of monotonic time or the 'sticky' bit should be set on the file.

If $XDG_RUNTIME_DIR is not set applications should fall back to a replacement directory with similar capabilities and print a warning message. Applications should use this directory for communication and synchronization purposes and should not place larger files in it, since it might reside in runtime memory and cannot necessarily be swapped out to disk.
4 Referencing this specification #

Other specifications may reference this specification by specifying the location of a data file as $XDG_DATA_DIRS/subdir/filename. This implies that:

    Such file should be installed to $datadir/subdir/filename with $datadir defaulting to /usr/share.

    A user-specific version of the data file may be created in $XDG_DATA_HOME/subdir/filename, taking into account the default value for $XDG_DATA_HOME if $XDG_DATA_HOME is not set.

    Lookups of the data file should search for ./subdir/filename relative to all base directories specified by $XDG_DATA_HOME and $XDG_DATA_DIRS . If an environment variable is either not set or empty, its default value as defined by this specification should be used instead.

Specifications may reference this specification by specifying the location of a configuration file as $XDG_CONFIG_DIRS/subdir/filename. This implies that:

    Default configuration files should be installed to $sysconfdir/xdg/subdir/filename with $sysconfdir defaulting to /etc.

    A user-specific version of the configuration file may be created in $XDG_CONFIG_HOME/subdir/filename, taking into account the default value for $XDG_CONFIG_HOME if $XDG_CONFIG_HOME is not set.

    Lookups of the configuration file should search for ./subdir/filename relative to all base directories indicated by $XDG_CONFIG_HOME and $XDG_CONFIG_DIRS . If an environment variable is either not set or empty, its default value as defined by this specification should be used instead.

If, when attempting to write a file, the destination directory is non-existent an attempt should be made to create it with permission 0700. If the destination directory exists already the permissions should not be changed. The application should be prepared to handle the case where the file could not be written, either because the directory was non-existent and could not be created, or for any other reason. In such case it may choose to present an error message to the user.

When attempting to read a file, if for any reason a file in a certain directory is unaccessible, e.g. because the directory is non-existent, the file is non-existent or the user is not authorized to open the file, then the processing of the file in that directory should be skipped. If due to this a required file could not be found at all, the application may choose to present an error message to the user.

A specification that refers to $XDG_DATA_DIRS or $XDG_CONFIG_DIRS should define what the behaviour must be when a file is located under multiple base directories. It could, for example, define that only the file under the most important base directory should be used or, as another example, it could define rules for merging the information from the different files.

© 2026 Freedesktop.org
