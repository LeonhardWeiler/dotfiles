local M = {}

-- Speichert die Job-ID von Zathura, falls geöffnet
local zathura_job = nil

-- rewrite this Toggle Zathura funktion to open pdfs with the default browser as seen in the next function OpenBrowser

-- 📖 PDF mit Zathura öffnen oder schließen
function M.ToggleZathura()
  local filename = vim.fn.expand('%:r')
  if zathura_job then
    vim.fn.jobstop(zathura_job)
    zathura_job = nil
    vim.notify("🛑 Closed Zathura")
  else
    zathura_job = vim.fn.jobstart({ "zathura", filename .. ".pdf" })
    vim.notify("📖 Opened Zathura")
  end
end

-- 🌐 HTML oder JS-Projekt im Browser öffnen
function M.OpenBrowser()
  local filepath = vim.fn.expand("%:p")
  local filetype = vim.bo.filetype

  if filetype == "html" then
    vim.fn.jobstart({ "xdg-open", filepath }, { detach = true })
  elseif filetype == "javascript" then
    local index_path = vim.fn.expand("%:p:h") .. "/../html/index.html"
    vim.fn.jobstart({ "xdg-open", index_path }, { detach = true })
  else
    vim.notify("📛 Unsupported filetype for browser preview")
  end
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

-- Whitespace am Zeilenende beim Speichern entfernen
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", {}),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Weitere nützliche Einstellungen für Textdateien
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "txt", "md" },
  callback = function()
    vim.opt.wrap = true
    vim.opt.linebreak = true
    vim.keymap.set("n", "j", "gj", { noremap = true })
    vim.keymap.set("n", "k", "gk", { noremap = true })
  end
})

return M

