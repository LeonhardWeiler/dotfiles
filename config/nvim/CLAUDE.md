# CLAUDE.md

Notes for working on this Neovim configuration.

## Overview

Personal Neovim config (Neovim >= 0.11, developed on 0.12) based on lazy.nvim.
Keyboard-first (mouse disabled). Comment language: **English**.

## Structure

- `init.lua` loads in order: `config.lazy` -> `config.options` ->
  `config.keymaps` -> `config.autocmds`.
- `lua/config/` holds the non-plugin configuration.
- `lua/plugins/` - **one file per plugin/area**; lazy collects them
  automatically via `{ import = "plugins" }`. Each file returns a lazy spec
  (table).
- `autocmds.lua` returns a module `M` (including `M.OpenBrowser`) used in
  `keymaps.lua`.

## Verification (no test framework)

- **Lua syntax** of a file: `luajit -bl <file.lua> >/dev/null`
- **Config loads without errors**: `nvim --headless "+lua print('ok')" +qa`
- **Full start incl. plugin install/clean**: `nvim --headless "+qa"`
  (installs missing plugins, updates `lazy-lock.json`).
- For single modules: `nvim --headless "+lua require('config.autocmds')" +qa`.
- **Lua formatting** of the config: `stylua lua/` (or `stylua --check lua/` to
  check). The `stylua.toml` in the repo root fixes **spaces with width 2** -
  matching `options.lua`. stylua also runs on format-on-save (conform).

Keep the indentation at 2 spaces (see `options.lua`/`stylua.toml`).

## Plugin management

- Versions are pinned in `lazy-lock.json`. After changes to plugin specs the
  lockfile is rewritten by a `nvim --headless "+qa"` start - commit that change
  along with it.
- LSP servers are installed via `mason-lspconfig` (`ensure_installed`),
  formatters/linters/`tree-sitter-cli` via `mason-tool-installer`
  (`lua/plugins/mason-tools.lua`).

## Notable specifics

- **Treesitter runs on the `main` branch** (not master). Parsers are installed
  into the `site` directory via `require('nvim-treesitter').install{…}` and need
  the `tree-sitter` CLI (comes via mason). Highlighting/indent are enabled in
  `treesitter.lua` via a `FileType` autocmd (`vim.treesitter.start`). Treesitter
  text objects and incremental selection are **deliberately not** used.
- **mini.icons replaces nvim-web-devicons**; a `package.preload` mock in
  `plugins.lua` keeps plugins working that expect
  `require("nvim-web-devicons")`.
- **Completion is blink.cmp** (not nvim-cmp). LSP capabilities come from
  `require("blink.cmp").get_lsp_capabilities()`.
- **mason uses the `mason-org` organization** (no longer `williamboman`).
- **`prettier`, deliberately not `prettierd`** (`plugins/conform.lua`):
  prettierd is a daemon that outlives nvim and stays resident (~60 MB). css is
  formatted by biome instead; html and markdown keep prettier because biome's
  html formatter is experimental/off and biome has no markdown formatter. Do not
  "optimize" this back to prettierd.

## Conventions

- New plugins as their own file under `lua/plugins/`.
- English comments, sparse and explanatory (why, not what).
- Give keymaps a `desc`.
- Preserve existing behaviour where it makes sense.
