local M = {}

-- 🌐 Aktuelle Datei mit dem Standardprogramm (Browser) öffnen.
-- xdg-open reicht die Datei an den im System hinterlegten Handler weiter, sodass
-- alle vom Browser darstellbaren Typen (PDF, HTML, SVG, Bilder …) geöffnet werden.
function M.OpenBrowser()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("📛 Kein Dateipfad für den aktuellen Buffer", vim.log.levels.WARN)
    return
  end
  vim.fn.jobstart({ "xdg-open", filepath }, { detach = true })
end

-- === Autocommands ===

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- TextYank: visuelles Highlight nach Yank
autocmd("TextYankPost", {
  group = augroup("HighlightYank", {}),
  pattern = "*",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 100 })
  end,
})

-- Trailing-Whitespace wird bewusst NICHT per BufWritePre getrimmt: conform
-- (Format-on-Save) uebernimmt das fuer formatierte Dateitypen. Ein eigener
-- `%s/\s\+$//e` liefe redundant und wuerde ohne keeppatterns Suchhistorie
-- und Cursor-Position veraendern.

-- Weitere nützliche Einstellungen für Textdateien
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "txt", "md" },
  callback = function()
    vim.opt.wrap = true
    vim.opt.linebreak = true
    vim.keymap.set("n", "j", "gj", { noremap = true })
    vim.keymap.set("n", "k", "gk", { noremap = true })
  end,
})

return M
