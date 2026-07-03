# CLAUDE.md

Hinweise für die Arbeit an dieser Neovim-Konfiguration.

## Überblick

Persönliche Neovim-Config (Neovim ≥ 0.11, entwickelt auf 0.12) auf Basis von
lazy.nvim. Keyboard-first (Maus deaktiviert). Sprache der Kommentare: **Deutsch**.

## Struktur

- `init.lua` lädt in Reihenfolge: `config.lazy` → `config.options` →
  `config.keymaps` → `config.autocmds`.
- `lua/config/` enthält die nicht-plugin-bezogene Konfiguration.
- `lua/plugins/` — **eine Datei pro Plugin/Bereich**; lazy sammelt sie über
  `{ import = "plugins" }` automatisch ein. Jede Datei gibt eine lazy-Spec
  (Tabelle) zurück.
- `autocmds.lua` gibt ein Modul `M` zurück (u. a. `M.OpenBrowser`), das in
  `keymaps.lua` verwendet wird.

## Verifikation (kein Test-Framework)

- **Lua-Syntax** einer Datei: `luajit -bl <datei.lua> >/dev/null`
- **Config lädt fehlerfrei**: `nvim --headless "+lua print('ok')" +qa`
- **Voller Start inkl. Plugin-Install/-Clean**: `nvim --headless "+qa"`
  (installiert fehlende Plugins, aktualisiert `lazy-lock.json`).
- Für einzelne Module: `nvim --headless "+lua require('config.autocmds')" +qa`.
- **Lua-Formatierung** der Config: `stylua lua/` (bzw. `stylua --check lua/` zum
  Prüfen). Die `stylua.toml` im Repo-Root fixiert **Spaces mit 2 Breite** —
  passend zu `options.lua`. stylua läuft auch per Format-on-Save (conform).

Halte die Einrückung bei 2 Spaces (siehe `options.lua`/`stylua.toml`).

## Plugin-Management

- Versionen sind in `lazy-lock.json` gepinnt. Nach Änderungen an Plugin-Specs
  wird die Lockdatei durch einen `nvim --headless "+qa"`-Start neu geschrieben —
  diese Änderung mitcommitten.
- LSP-Server werden über `mason-lspconfig` (`ensure_installed`) installiert,
  Formatter/Linter/`tree-sitter-cli` über `mason-tool-installer`
  (`lua/plugins/mason-tools.lua`).

## Wichtige Besonderheiten

- **Treesitter läuft auf dem `main`-Branch** (nicht master). Parser werden per
  `require('nvim-treesitter').install{…}` ins `site`-Verzeichnis installiert und
  benötigen die `tree-sitter`-CLI (kommt über mason). Highlighting/Indent werden
  in `treesitter.lua` per `FileType`-Autocmd (`vim.treesitter.start`) aktiviert.
  Treesitter Text Objects und Incremental Selection werden **bewusst nicht**
  verwendet.
- **mini.icons ersetzt nvim-web-devicons**; per `package.preload`-Mock in
  `plugins.lua` funktionieren Plugins weiter, die `require("nvim-web-devicons")`
  erwarten.
- **Completion ist blink.cmp** (nicht nvim-cmp). LSP-Capabilities kommen aus
  `require("blink.cmp").get_lsp_capabilities()`.
- **mason nutzt die `mason-org`-Organisation** (nicht mehr `williamboman`).

## Konventionen

- Neue Plugins als eigene Datei unter `lua/plugins/`.
- Deutsche Kommentare, sparsam und erklärend (Warum, nicht Was).
- Keymaps mit `desc` versehen.
- Bestehendes Verhalten bewahren, sofern sinnvoll.
