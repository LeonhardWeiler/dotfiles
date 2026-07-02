# Keymap-Vorschläge

Vorschläge zur Auflösung von Keymap-Kollisionen. **Nichts hiervon ist umgesetzt** –
lang genutzte Shortcuts bleiben bewusst unverändert. Dies ist nur eine Sammlung von
Optionen, aus der du bei Gelegenheit wählen kannst.

## UX-1 · Kollision auf `<leader>s`

`<leader>s` ist derzeit **gleichzeitig** eine vollständige Aktion und ein Präfix:

- **Vollständige Aktion** (`lua/config/keymaps.lua:25`):
  `<leader>s` → Suchen & Ersetzen des Worts unter dem Cursor
  (`:%s/\<WORT\>/WORT/gI`).
- **Präfix** der Telescope-Maps (`lua/plugins/telescope.lua`):
  `<leader>sf` find files · `sg` live grep · `sh` help tags · `sc` colorscheme ·
  `sq` quickfix · `sl` spell suggest · `sk` keymaps · `st` filetypes.

**Effekt:** Nach `<leader>s` muss Neovim erst `timeoutlen` (Default 1000 ms) abwarten,
ob noch ein Folgezeichen kommt. Das erzeugt eine spürbare Verzögerung bei allen
`<leader>s…`-Telescope-Maps und ist mehrdeutig.

### Option A – Standalone-Aktion umlegen (empfohlen)

Die vollständige Aktion auf eine kollisionsfreie Taste legen, damit `<leader>s…`
ein sauberes Such-Präfix bleibt. Kandidaten:

| Neue Taste     | Merkhilfe                        |
| -------------- | -------------------------------- |
| `<leader>S`    | großes S = „Substitute"          |
| `<leader>rw`   | „replace word"                   |
| `<leader>sr`   | „search & replace" (bleibt unter `s`, ergänzt das Präfix) |

Beispiel (nur zur Illustration, **nicht** committen ohne deine Zustimmung):

```lua
-- statt <leader>s
vim.keymap.set(
  "n",
  "<leader>S",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Wort unter Cursor ersetzen" }
)
```

### Option B – Telescope-Präfix umlegen

Alternativ das Telescope-Präfix von `<leader>s` auf `<leader>f` („find") verschieben
(`<leader>ff`, `fg`, `fh`, …). Dann bleibt `<leader>s` als Standalone-Ersetzen frei.
Nachteil: `f` ist stärker eingespielt umzugewöhnen als eine einzelne Taste.

### Option C – `timeoutlen` senken

Kein echtes Auflösen der Mehrdeutigkeit, aber die Verzögerung verkürzen
(z. B. `vim.opt.timeoutlen = 300`). Wirkt global und betrifft alle Mappings.

## Weitere Beobachtungen (keine Kollision, nur zur Info)

- `K` ist doppelt belegt: global „J ohne Cursor-Bewegung"-Analogon
  (`mzJ`z` liegt auf `J`) und im LSP-`LspAttach` `K` → `vim.lsp.buf.hover`.
  Das ist gewollt (hover nur bei aktivem LSP) und daher keine Kollision.
