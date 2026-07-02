Du bist ein erfahrener Neovim-Entwickler und kennst den aktuellen Stand des Neovim-Ökosystems (Neovim 0.11+), Lua, Lazy.nvim und die Best Practices von 2026.

Analysiere meine gesamte Neovim-Konfiguration rekursiv.

Deine Aufgabe ist nicht nur Fehler zu beheben, sondern die komplette Konfiguration auf den modernsten, performantesten und wartbarsten Stand zu bringen.

## Ziele

- Verwende ausschließlich aktuelle APIs.
- Entferne veraltete Patterns.
- Nutze aktuelle Best Practices.
- Reduziere unnötige Plugins.
- Verbessere Performance.
- Vereinfache die Konfiguration.
- Vermeide doppelte Funktionalität.
- Bewahre bestehendes Verhalten, sofern es sinnvoll ist.

---

## HARTE MIGRATIONSVORGABEN (MUSS umgesetzt werden)

- Entferne jedes bestehende autopairs Plugin vollständig.
  → Ersetze es durch `echasnovski/mini.pairs` (keine Alternativen verwenden).

- Ersetze `nvim-web-devicons` vollständig durch:
  → `echasnovski/mini.icons`
  Falls ein Plugin zwingend web-devicons erwartet, adaptiere die Konfiguration entsprechend oder finde eine kompatible Lösung.

---

## LSP

Nutze die neuen Neovim-0.11+-APIs.

Verwende:

- mason.nvim
- mason-lspconfig.nvim
- nvim-lspconfig

Nutze die neue `vim.lsp.config()` API.

Konfiguriere automatisch alle Server sauber.

Verwende diese LSPs:

- lua_ls
- html
- cssls
- vtsls
- gopls
- marksman
- tinymist
- emmet_ls

Nutze `lazydev.nvim` für Lua.

Konfiguriere `lua_ls` optimal für Neovim.

---

## Completion

Ersetze `nvim-cmp` durch `blink.cmp`, sofern dies sinnvoll ist.

Nutze:

- blink.cmp
- LuaSnip

Aktiviere sinnvolle Features wie:

- Ghost Text
- Signature Help
- automatische Dokumentation
- Snippet Support

---

## Formatter

Nutze ausschließlich `conform.nvim`.

Verwende folgende Formatter:

Lua
- stylua

JS / TS / JSX / TSX / JSON
- biome

HTML
- prettierd

CSS
- prettierd

Markdown
- prettierd

Go
- goimports
- gofumpt

Typst
- typstyle

Format on Save soll sauber implementiert sein.

---

## Linter

Nutze ausschließlich `nvim-lint`.

Konfiguriere:

JavaScript / TypeScript
- biome

Lua
- selene

Go
- golangci-lint

Markdown
- markdownlint

Füge sinnvolle Autocommands hinzu.

---

## Treesitter

Prüfe die Konfiguration.

Aktualisiere sie auf Best Practices.

Installiere nur benötigte Parser.

Aktiviere:

- Highlight
- Indent
- Incremental Selection
- Textobjects (falls sinnvoll)

---

## Performance

Überprüfe:

- Lazy Loading
- Event Loading
- Dependencies
- unnötige Plugins
- doppelte Plugins
- doppelte Keymaps
- unnötige Autocommands
- unnötige globale Variablen
- Startzeit

Optimiere alles.

---

## Plugin-Auswahl

Suche aktiv nach moderneren Alternativen.

Ersetze Plugins nur, wenn die Alternative objektiv besser ist hinsichtlich:

- Wartung
- Performance
- API
- Community
- Zukunftssicherheit

Falls du ein Plugin ersetzt, erkläre warum.

---

## Codequalität

- Entferne Dead Code.
- Entferne Duplikate.
- Vereinheitliche Formatierung.
- Nutze idiomatisches Lua.
- Nutze lokale Variablen.
- Nutze aktuelle Lazy.nvim-Patterns.
- Nutze aktuelle Neovim-APIs.

---

## Sicherheit

Keine experimentellen Plugins.

Keine Alpha-Versionen.

Keine Forks ohne gute Begründung.

Nur aktiv gepflegte Projekte.

---

## Dokumentation

Erstelle am Ende einen Report:

1. Welche Dateien wurden geändert.
2. Welche Plugins wurden ersetzt.
3. Warum.
4. Welche APIs wurden modernisiert.
5. Welche Performanceverbesserungen vorgenommen wurden.
6. Welche veralteten Patterns entfernt wurden.
7. Welche Plugins entfernt wurden.
8. Welche neuen Plugins hinzugefügt wurden.

---

## Arbeitsweise

Arbeite Datei für Datei.

Erkläre kurz jede Änderung.

Falls mehrere Möglichkeiten existieren, entscheide dich für die Lösung, die heute als Best Practice gilt.

Treffe keine Annahmen. Lies die komplette Konfiguration, bevor du Änderungen vornimmst.

Wenn du feststellst, dass Teile der Konfiguration bereits modern und optimal sind, lasse sie unverändert.

Das Ziel ist eine schlanke, moderne, performante und langfristig wartbare Neovim-Konfiguration.

Nutze Websuche bzw. verfügbare Dokumentation, um aktuelle Best Practices, API-Änderungen und Empfehlungen der offiziellen Dokumentation der verwendeten Plugins zu überprüfen. Verlasse dich nicht ausschließlich auf Trainingswissen. Prüfe insbesondere die Dokumentation von Neovim, lazy.nvim, mason.nvim, mason-lspconfig.nvim, nvim-lspconfig, blink.cmp, conform.nvim und nvim-lint, bevor du Änderungen vornimmst.
