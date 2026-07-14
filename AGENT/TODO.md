XDG Base Directory Specification compliance — audit result.

Not everything is compliant. Below is what deviates from the spec and how to
fix it, followed by what is already fine and the deviations we cannot fix.

## Not compliant — fix these

xdg-1  bash history lives in the *config* dir, but history is *state* data.
       `config/bash/.bashrc:3` sets `HISTFILE=~/.config/bash/.bash_history`.
       The spec lists "history" explicitly under $XDG_STATE_HOME (§ state).
       Fix: `HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"`
       (keep the `mkdir -p "$(dirname "$HISTFILE")"` line right after it).

xdg-2  `~/.dircolors` is a bare home dotfile, not under $XDG_CONFIG_HOME.
       `setup/links.conf:49` links `config/bash/.dircolors -> ~/.dircolors`
       and `config/bash/.bashrc:40` does `eval "$(dircolors ~/.dircolors)"`.
       Fix: retarget the link to `~/.config/dircolors` and change the eval to
       `eval "$(dircolors "${XDG_CONFIG_HOME:-$HOME/.config}/dircolors")"`.

xdg-3  git uses a non-native filename plus an env-var workaround. git natively
       reads `$XDG_CONFIG_HOME/git/config`; the repo ships `config/git/.gitconfig`
       and forces it via `GIT_CONFIG_GLOBAL` (`config/bash/.bashrc:39`, and
       `config/systemd-user/dotfiles-sync.service:10`).
       Fix: rename source to `config/git/config`, retarget the link to
       `~/.config/git/config`, drop the `GIT_CONFIG_GLOBAL` export from
       `.bashrc` and the `Environment=` line from the sync service. Also update
       the scrub path in `install` (lines ~497–520) and the two `CLAUDE.md`
       mentions (lines 59, 189). (`config/git/ignore -> ~/.config/git/ignore`
       is already native — leave it.)

xdg-4  typst *packages* (downloadable data) are pointed at the *config* dir.
       `config/bash/.bashrc:38` sets `TYPST_PACKAGE_PATH="$HOME/.config/typst/packages"`;
       typst's native local-package path is `$XDG_DATA_HOME/typst/packages`.
       Fix: either drop the override (let typst use `~/.local/share/typst`) or
       set it to `${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages`, and move
       the `config/typst/packages` link target to match.

## Already compliant — leave as is

- `~/.local/bin` for user scripts (`config/usrbin/*`, PATH via `.bashrc`).
- Wallpapers -> `~/.local/share/wallpapers` ($XDG_DATA_HOME).
- `GOPATH=~/.local/share/go`, `npm_config_cache=~/.cache/npm` (already XDG'd).
- `~/.config/mimeapps.list`, `~/.config/git/ignore`, and every app under
  `~/.config/` (alacritty, btop, hypr, keepassxc, mako, mpv, nvim, qt5ct, rofi).

## Cannot fix from the dotfiles — external limitations

- bash reads `~/.bashrc` / `~/.bash_profile` from `$HOME` unconditionally; there
  is no XDG path for them without a home stub that re-sources a moved copy.
- Claude Code hardcodes `~/.claude/` (settings.json, skills) instead of
  `~/.config/claude`; out of our control.
