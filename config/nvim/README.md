# Neovim configuration

Personal, keyboard-first Neovim config based on
[lazy.nvim](https://github.com/folke/lazy.nvim). Tested with **Neovim 0.12**
(needs at least 0.11 because of the new `vim.lsp.config` API and the
nvim-treesitter `main` branch).

## Installation

```sh
git clone <repo> ~/.config/nvim
nvim
```

On the first start lazy.nvim installs all plugins automatically; mason and
mason-tool-installer pull in the LSP servers, formatters, linters and the
`tree-sitter` CLI.

### Requirements

- **Neovim >= 0.11**
- **git** and a **C compiler** (to compile the Treesitter parsers)
- **Nerd Font** (icons via mini.icons)
- **ripgrep** / **fd** (recommended for Telescope)
- **xdg-open** (for `<leader>ob`, opens the current file in the default program)
- Node.js/Go/etc. depending on the LSP/formatter you use (managed via mason)

## Structure

```
init.lua                 entry point: loads config.lazy -> options -> keymaps -> autocmds
lua/config/
  lazy.lua               lazy.nvim bootstrap, leader keys
  options.lua            editor options (incl. clipboard=unnamedplus)
  keymaps.lua            global keymaps
  autocmds.lua           autocommands + OpenBrowser
lua/plugins/             one file per plugin/area (auto-import)
```

## Plugins

| Area          | Plugin(s) |
|---------------|-----------|
| Manager       | lazy.nvim |
| Theme         | kanagawa.nvim |
| File manager  | oil.nvim |
| Search        | telescope.nvim, plenary.nvim |
| Navigation    | harpoon (`harpoon2`) |
| Statusline    | lualine.nvim |
| Git           | gitsigns.nvim |
| Comments      | Comment.nvim |
| Editing       | mini.pairs, mini.icons |
| Treesitter    | nvim-treesitter (`main`) |
| LSP           | mason.nvim, mason-lspconfig.nvim, nvim-lspconfig, lazydev.nvim, mason-tool-installer.nvim |
| Completion    | blink.cmp, LuaSnip, friendly-snippets |
| Formatter     | conform.nvim (stylua, biome, prettierd, goimports+gofumpt, typstyle) |
| Linter        | nvim-lint (biome, golangci-lint) |
| Typst         | typst-preview.nvim |

## Keymaps (selection)

Leader = `<Space>`.

### General
| Key | Action |
|-------|--------|
| `<leader>pv` | Oil (file manager) |
| `<leader>ob` | Open the current file in the default program/browser |
| `<leader>S` | Search & replace word under cursor |
| `<leader>sd` | Diagnostics into the quickfix list (shown with `<leader>sq`) |
| `<leader>r` (visual) | Paste over selection without overwriting the register |
| `J`/`K` (visual) | Move lines |

### Harpoon
| Key | Action |
|-------|--------|
| `<leader>a` | Pin file |
| `<leader>h` | Menu |
| `<leader>1`…`<leader>4` | Jump to file 1-4 |

### Telescope
`<leader>s` + `f` files · `g` live grep · `h` help · `c` colorscheme ·
`q` quickfix · `l` spelling · `k` keymaps · `t` filetypes

### LSP (buffer-local on attach)
`gd` definition · `gr` references · `K` hover · `<leader>rn` rename ·
`<leader>ca` code action · `<leader>e` diagnostics · `[d`/`]d` navigate diagnostics

## Formatting & linting

- **Format-on-save** via conform.nvim (LSP fallback if no formatter is
  configured).
- **Linting** via nvim-lint on `BufReadPost`/`BufWritePost`/`InsertLeave`.
  Lua diagnostics come from `lua_ls` (LSP); Markdown is only formatted by prettierd.
- **Diagnostics** are shown multi-line under the affected line via
  `virtual_lines`; `<leader>e` additionally opens the diagnostic float.
