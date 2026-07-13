Overall, I think you've made the right choice.

For a dotfiles installer that targets Linux, **Bash is the natural implementation language**. It keeps the barrier to entry extremely low—every Arch installation already has Bash, `ln`, `mkdir`, `systemctl`, `install`, `sudo`, etc. A user shouldn't have to install Python, Go, Rust, or Node just to install dotfiles.

That said, I'd distinguish between **the language choice** and **the structure**.

## Bash is the right language

Your installer is essentially an orchestration script. It:

- creates symlinks
- copies a few files
- calls `systemctl`
- calls `pacman`
- calls `locale-gen`
- calls `mkinitcpio`

Those are all shell operations.

If this were rewritten in Python, most of the code would become:

```python
subprocess.run(["systemctl", ...])
subprocess.run(["ln", ...])
subprocess.run(["mkdir", ...])
```

which isn't really an improvement.

---

## Things I like

### Data-driven design

This is probably my favorite part.

Instead of

```bash
ln -s ...
ln -s ...
ln -s ...
ln -s ...
```

you have

```text
links.conf
```

and the installer is generic.

That scales very well.

---

### Idempotency

This is something a surprising number of dotfile repos get wrong.

Running

```bash
./install
```

multiple times is safe.

That's excellent.

---

### `--force`

Backing up to `.bak` is much better than blindly overwriting.

---

### `status`

I really like having

```bash
./install status
```

It's much nicer than wondering whether something linked correctly.

---

### Registry for setup steps

```bash
register_step
```

is a nice abstraction.

It avoids enormous `case` statements later.

---

## Where I'd improve it

This script is almost **700 lines**.

That's the point where maintenance starts becoming harder.

Not because Bash can't do it, but because everything lives in one file.

I would split it.

For example

```
install
setup/
    steps.sh
    links.sh
    systemd.sh
    output.sh
    parser.sh
```

Then

```bash
source setup/output.sh
source setup/parser.sh
source setup/links.sh
...
```

Now each file is maybe 100–150 lines.

---

## Separate data from code even more

For example

```bash
SYSTEM_UNITS=(...)
```

could live in

```
setup/system-units.txt
```

Likewise

```
GROUP_LIST
```

could become

```
setup/groups.txt
```

Then your installer becomes almost entirely generic.

---

## Validation

I'd add

```bash
./install validate
```

which checks

- duplicate targets
- missing sources
- broken glob
- malformed links.conf
- invalid source path
- duplicate source

without touching the filesystem.

Then CI simply runs

```bash
./install validate
```

---

## Better testing

You already have

```
status
```

I'd add a hidden command

```
./install selftest
```

that creates a temporary HOME

```
mktemp -d

HOME=...

run installer

verify

exit
```

That lets you test almost everything without a VM.

---

## Slight refactoring

For example

```bash
link_one
unlink_one
status_one
clean_one
```

all compute

```bash
target="$(expand_target ...)"
needs_root ...
```

I'd probably introduce

```bash
prepare_target()
```

returning

- source
- target
- root

to remove duplicated logic.

---

## One thing I would not change

Some people will say

> Rewrite it in Python.

I wouldn't.

For this kind of project I think Bash is actually preferable.

Users already trust shell installers.

The fewer dependencies the better.

---

## My biggest recommendation

The one thing I'd seriously consider is turning it into a small framework instead of one large script.

Something like

```
install                 (~120 lines)

setup/
    parser.sh
    links.sh
    steps.sh
    output.sh
    validate.sh
```

Then `install` mostly becomes

```bash
parse_args

load_links

case "$CMD" in
    link)
        do_symlinks
        ;;
    setup)
        choose_steps
        run_steps
        ;;
    status)
        status
        ;;
esac
```

The behavior doesn't change, but the code becomes much easier to navigate and extend.

**Overall assessment:** I'd rate it around **8.5–9/10** for a personal dotfiles installer. The architecture is thoughtful: it's data-driven, idempotent, supports dry runs, has clear subcommands, and avoids unnecessary dependencies. The main weakness isn't the choice of Bash—it's that the implementation has grown to the point where splitting it into a handful of sourced modules would make future maintenance significantly easier without sacrificing the simplicity of a single `./install` entry point.

---

These are all good design questions. I'll go through them one by one.

---

## Is it POSIX compliant?

No.

It's explicitly a **Bash script**, and that's perfectly fine.

Some examples of Bash-specific features you use:

```bash
#!/usr/bin/env bash
```

Associative arrays:

```bash
declare -A STEP_DESC STEP_FN SELECTED
```

Indexed arrays:

```bash
USER_UNITS=(...)
```

`[[ ... ]]`

```bash
if [[ "$s" == *"*"* ]]; then
```

`shopt`

```bash
shopt -s nullglob
```

Process substitution

```bash
comm -23 <(...) <(...)
```

`local`

```bash
local reply
```

Those are not POSIX.

---

## Would it run on OpenBSD?

It depends.

### If Bash is installed

Yes, mostly.

OpenBSD ships with

```
/bin/ksh
```

as the default shell.

If the user installs Bash

```
pkg_add bash
```

then

```
#!/usr/bin/env bash
```

will find it.

---

### But...

Many commands are Linux-specific.

For example

```
systemctl
```

doesn't exist.

Neither do

```
mkinitcpio
pacman
yay
locale-gen
```

etc.

So the script would immediately start skipping or failing parts.

The linking functionality would probably work.

The Arch setup functionality obviously won't.

---

## Should you make it POSIX?

Personally, **no**.

Your repository is

> Arch Linux + Hyprland

There's little value in restricting yourself to POSIX shell if the project is intentionally Linux-specific.

I would instead lean further into Bash and document:

> Requires Bash ≥ 5.0.

---

# Bash framework?

Personally, I wouldn't.

There are frameworks like

- bashly
- gum
- charmbracelet/gum
- bash3boilerplate

but your current script already has a clean CLI.

The only one I'd maybe use is **gum**.

Example

```
gum choose
gum confirm
gum spin
gum style
```

It gives really nice TUI prompts.

But...

it's another dependency.

Your current installer's biggest selling point is

> dependency-free

I'd keep that.

---

# Better UI?

Instead of a framework I'd improve your own helpers.

For example

```bash
info
warn
ok
```

could become

```
info "Installing packages..."
```

↓

```
ℹ Installing packages...
```

and maybe

```
✔ Linked ~/.bashrc
```

etc.

You've already started doing that.

---

# Allow disabling configs?

This is something I'd definitely add.

For example

```
setup/links.conf
```

could become

```
config/nvim        ~/.config/nvim
config/bash        ~/.bashrc
config/mpv         ~/.config/mpv
```

and

```
setup/profile.conf
```

could contain

```
disable=mpv
disable=typst
disable=keepassxc
```

The installer simply ignores those entries.

---

Or even nicer:

```
./install \
    --exclude mpv \
    --exclude typst
```

or

```
./install \
    --only bash \
    --only git \
    --only nvim
```

That makes testing much easier too.

---

# What happens if links.conf contains an error?

At the moment:

Suppose

```
config/foo
```

(no target)

You do

```bash
warn ...
continue
```

So the installer continues.

---

Suppose

```
config/does_not_exist ~/.config/foo
```

Then

```
source missing
```

and continue.

---

Suppose

```
same target twice
```

Nothing notices.

Second one wins.

That's bad.

---

Suppose

```
../../etc/passwd
```

as a source.

Currently nothing stops it.

---

Suppose

```
../../../home/foo
```

Probably also accepted.

---

# I'd add a validation phase.

Before doing anything.

Example:

```
Reading links.conf...

✓ syntax

✓ unique targets

✓ unique sources

✓ source exists

✓ source inside repository

✓ target valid

✓ no duplicate entries

✓ globs matched

✓ no absolute sources

✓ no empty lines

✓ no tabs inside path

✓ no trailing garbage

Validation successful.
```

Only then

```
Creating links...
```

---

# Make malformed config fatal

Personally I'd make parsing stricter.

Instead of

```
warning

continue
```

I'd do

```
Error:

links.conf:42

Missing target

Aborting.
```

If the configuration itself is broken, I don't want a partial installation.

---

# Duplicate detection

I'd absolutely add

```
duplicate target

duplicate source
```

using associative arrays.

For example

```bash
declare -A seen_target

if [[ ${seen_target[$target]+x} ]]; then
    fatal ...
fi
```

---

# Validate sources stay inside repo

Example

```
../../../../etc/passwd
```

should be rejected.

You can compare

```
realpath
```

against

```
$BASEDIR
```

---

# Unknown target prefixes

You currently allow

```
~
/etc
```

I'd maybe reject

```
/tmp
```

```
/usr
```

unless explicitly allowed.

---

# Globs

Currently

```
config/usrbin/*
```

with no match

↓

warning

continue

I'd probably make that fatal unless the glob is explicitly marked optional.

---

# I'd split parsing

Right now parsing and execution are mixed.

I'd instead do

```
Parse

↓

Validate

↓

Expand globs

↓

Build table

↓

Execute
```

Then execution never has to worry about malformed entries.

---

## Overall

I think the script is already well above the average dotfiles installer. If I were evolving it further, I would prioritize **validation** over **new features**. A strict parser that rejects malformed or ambiguous `links.conf` files, detects duplicate targets, ensures sources stay inside the repository, and fails before making any changes will make the installer much more robust. After that, I'd add an `--only`/`--exclude` mechanism so users (or you, when testing) can install just a subset of configurations.

As for portability, I wouldn't aim for POSIX. Your project is intentionally built around Arch Linux, `systemd`, `pacman`, and Hyprland, so embracing Bash is a reasonable trade-off. The biggest improvements now are in correctness, maintainability, and validation—not in making it run on systems it isn't designed to support.

---

Yes, absolutely. In fact, your installer is already **90% of the way there** because you've separated **"what to install"** from **"how to link configs"**. The biggest obstacle isn't Bash—it's that some of your setup steps assume Arch and `systemd`.

I'd think about the project in terms of **three layers**:

```
configs
    ↓
generic installer
    ↓
platform-specific setup
```

The first two are already mostly distro-independent.

## Layer 1: Linking (portable)

Things like

- reading `links.conf`
- creating symlinks
- `status`
- `unlink`
- `clean`
- `--force`

work on essentially every Linux distribution.

These should remain completely generic.

---

## Layer 2: System configuration (mostly portable)

Many of these are portable too.

For example:

```
timezone
groups
sudoers
fonts
```

exist on virtually every Linux distribution.

The commands may differ slightly, but the concepts are universal.

---

## Layer 3: Distribution-specific

This is where things diverge.

| Feature         | Arch       | Fedora   | Void              | Artix                 |
| --------------- | ---------- | -------- | ----------------- | --------------------- |
| Package manager | pacman     | dnf      | xbps-install      | pacman                |
| Init            | systemd    | systemd  | runit             | OpenRC/runit/s6/dinit |
| Initramfs       | mkinitcpio | dracut   | dracut/mkinitcpio | mkinitcpio/dracut     |
| Bootloader      | anything   | anything | anything          | anything              |

This layer should be abstracted.

Instead of

```bash
do_programs_install() {
    yay ...
}
```

you'd have

```bash
install_packages() {
    distro_install_packages "$@"
}
```

---

# Detect the distribution

Linux already tells you.

```
/etc/os-release
```

contains something like

```
ID=arch
```

or

```
ID=fedora
```

or

```
ID=void
```

or

```
ID=artix
```

You can simply

```bash
source /etc/os-release

case "$ID" in
    arch)
        ...
        ;;
    fedora)
        ...
        ;;
    void)
        ...
        ;;
esac
```

---

# Detect the init system

Don't assume `systemd`.

Instead

```
command -v systemctl
```

or even better

```
ps -p 1
```

or

```
readlink /proc/1/exe
```

Examples:

```
systemd

runit

openrc-init

dinit

s6
```

Then dispatch accordingly.

Instead of

```bash
systemctl enable sshd
```

you'd call

```bash
enable_service sshd
```

whose implementation depends on the detected init system.

---

# Package installation

Don't hardcode `yay`.

Instead

```text
install_packages firefox git
```

↓

Arch

```
pacman -S
```

or

```
yay -S
```

↓

Fedora

```
dnf install
```

↓

Void

```
xbps-install
```

---

# Package manifests

This is probably where I'd change your design the most.

Right now you have

```
programs.txt
```

But package names differ.

Example:

```
Arch

ttf-jetbrains-mono-nerd

↓

Fedora

jetbrains-mono-fonts
```

or

```
pipewire

↓

pipewire

↓

pipewire
```

Some match.

Some don't.

I'd have

```
setup/packages/

arch.txt

fedora.txt

void.txt

artix.txt
```

Each can include a common file if you want to avoid duplication.

---

# System services

Similarly

Instead of

```
SYSTEM_UNITS
```

I'd have

```
setup/services/

systemd.txt

runit.txt

openrc.txt
```

---

# Fonts

These differ too.

Arch

```
noto-fonts
```

Fedora

```
google-noto-sans-fonts
```

Again, abstract it.

---

# Even nicer architecture

I'd almost make a tiny backend API.

```
install
```

calls

```
backend/install_packages

backend/enable_service

backend/regenerate_initramfs
```

Each distro provides its own implementation.

Like

```
backend/

arch.sh

fedora.sh

void.sh

artix.sh
```

At startup

```bash
source backend/$DISTRO.sh
```

Now your installer itself never mentions

- pacman
- yay
- dnf
- xbps
- systemctl

at all.

---

# What about Artix?

Artix is actually quite close to Arch.

Package installation can almost stay identical.

The big difference is the init system.

If someone uses

```
Artix + OpenRC
```

there is no

```
systemctl
```

So only your backend changes.

---

# What about Fedora?

Surprisingly easy.

Most of your dotfiles don't care.

You'd mainly need

- package backend
- initramfs backend (dracut instead of mkinitcpio)
- package manifests

Everything else works.

---

# What about Void?

Again, not too bad.

Main changes:

- xbps
- runit
- different package names

---

## Would I do it?

Yes—but only if you want your repository to become more than "my Arch setup."

I would **not** compromise the current simplicity. Instead, I'd introduce a thin compatibility layer with backends. Your installer would stay generic, and all distro-specific knowledge would live in a few small files.

Something like:

```
install
setup/
config/
backends/
    arch.sh
    fedora.sh
    void.sh
    artix.sh
```

where each backend implements the same small set of functions, for example:

- `install_packages`
- `remove_packages`
- `enable_service`
- `disable_service`
- `rebuild_initramfs`
- `refresh_font_cache`

This keeps the rest of the code unchanged and makes supporting additional distributions an incremental task rather than scattering `case "$ID"` checks throughout the installer. It's a pattern that's easy to extend and much easier to maintain as the project grows.

---

What I would do instead

I'd actually lean more into Bash.

For example:

getopts/manual parsing (or a small argument parser if you ever want one)
associative arrays
mapfile
printf -v
namerefs (declare -n) where appropriate

Those features make Bash code cleaner than trying to emulate them in POSIX shell.
