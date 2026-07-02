local M = {}

function M.OpenBrowser()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("📛 Kein Dateipfad für den aktuellen Buffer", vim.log.levels.WARN)
    return
  end
  vim.fn.jobstart({ "xdg-open", filepath }, { detach = true })
end

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
  group = augroup("HighlightYank", {}),
  pattern = "*",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 100 })
  end,
})

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
