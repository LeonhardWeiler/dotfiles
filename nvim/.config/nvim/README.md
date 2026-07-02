# Neovim-Konfiguration

Persönliche, keyboard-first Neovim-Config auf Basis von
[lazy.nvim](https://github.com/folke/lazy.nvim). Getestet mit **Neovim 0.12**
(benötigt mindestens 0.11 wegen der neuen `vim.lsp.config`-API und dem
nvim-treesitter-`main`-Branch).

## Installation

```sh
git clone <repo> ~/.config/nvim
nvim
```

Beim ersten Start installiert lazy.nvim alle Plugins automatisch; mason und
mason-tool-installer ziehen LSP-Server, Formatter, Linter und die
`tree-sitter`-CLI nach.

### Voraussetzungen

- **Neovim ≥ 0.11**
- **git** und ein **C-Compiler** (für das Kompilieren der Treesitter-Parser)
- **Nerd Font** (Icons via mini.icons)
- **ripgrep** / **fd** (empfohlen für Telescope)
- **xdg-open** (für `<leader>ob`, öffnet die aktuelle Datei im Standardprogramm)
- Node.js/Go/etc. je nach genutztem LSP/Formatter (werden über mason verwaltet)

## Struktur

```
init.lua                 Einstieg: lädt config.lazy → options → keymaps → autocmds
lua/config/
  lazy.lua               lazy.nvim-Bootstrap, Leader-Keys
  options.lua            Editor-Optionen (inkl. clipboard=unnamedplus)
  keymaps.lua            globale Keymaps
  autocmds.lua           Autocommands + OpenBrowser
lua/plugins/             je eine Datei pro Plugin/Bereich (auto-import)
```

## Plugins

| Bereich       | Plugin(s) |
|---------------|-----------|
| Manager       | lazy.nvim |
| Theme         | kanagawa.nvim |
| Dateimanager  | oil.nvim |
| Suche         | telescope.nvim, plenary.nvim |
| Navigation    | harpoon |
| Statusline    | lualine.nvim |
| Git           | gitsigns.nvim |
| Kommentare    | Comment.nvim |
| Bearbeitung   | mini.pairs, mini.icons |
| Treesitter    | nvim-treesitter (`main`) |
| LSP           | mason.nvim, mason-lspconfig.nvim, nvim-lspconfig, lazydev.nvim, mason-tool-installer.nvim |
| Completion    | blink.cmp, LuaSnip, friendly-snippets |
| Formatter     | conform.nvim (stylua, biome, prettierd, goimports+gofumpt, typstyle) |
| Linter        | nvim-lint (biome, golangci-lint) |
| Typst         | typst-preview.nvim |

## Keymaps (Auswahl)

Leader = `<Space>`.

### Allgemein
| Taste | Aktion |
|-------|--------|
| `<leader>pv` | Oil (Dateimanager) |
| `<leader>ob` | Aktuelle Datei im Standardprogramm/Browser öffnen |
| `<leader>S` | Wort unter Cursor suchen & ersetzen |
| `<leader>r` (visual) | Über Auswahl einfügen ohne Register zu überschreiben |
| `J`/`K` (visual) | Zeilen verschieben |

### Harpoon
| Taste | Aktion |
|-------|--------|
| `<leader>a` | Datei anheften |
| `<leader>h` | Menü |
| `<leader>1`…`<leader>4` | Datei 1–4 ansteuern |

### Telescope
`<leader>s` + `f` Dateien · `g` Live-Grep · `h` Hilfe · `c` Colorscheme ·
`q` Quickfix · `l` Rechtschreibung · `k` Keymaps · `t` Filetypes

### LSP (buffer-lokal bei Attach)
`gd` Definition · `gr` Referenzen · `K` Hover · `<leader>rn` Rename ·
`<leader>ca` Code-Action · `<leader>e` Diagnostik · `[d`/`]d` Diagnostik navigieren

## Formatierung & Linting

- **Format-on-Save** über conform.nvim (LSP-Fallback, falls kein Formatter
  konfiguriert ist).
- **Linting** über nvim-lint bei `BufReadPost`/`BufWritePost`/`InsertLeave`.
  Lua-Diagnosen liefert `lua_ls` (LSP); Markdown wird nur von prettierd formatiert.
- **Diagnosen** werden per `virtual_lines` mehrzeilig unter der betroffenen Zeile
  angezeigt; `<leader>e` öffnet zusätzlich den Diagnostik-Float.
