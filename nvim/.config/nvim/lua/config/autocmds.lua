local M = {}

-- Speichert den PID von Zathura, falls geöffnet
local zathura_pid = nil

-- 📄 LaTeX-Datei kompilieren
function M.CompileLatex()
  local filename = vim.fn.expand('%')
  vim.fn.jobstart({ 'pdflatex', filename }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("✔ Compilation finished successfully.")
      else
        vim.notify("✘ Compilation failed.", vim.log.levels.ERROR)
      end
    end,
  })
end

-- 📖 PDF mit Zathura öffnen oder schließen
function M.ToggleZathura()
  local filename = vim.fn.expand('%:r')
  if zathura_pid then
    vim.fn.system('kill ' .. zathura_pid)
    zathura_pid = nil
    vim.notify("🛑 Closed Zathura")
  else
    zathura_pid = tonumber(vim.fn.system('zathura ' .. filename .. '.pdf & echo $!'))
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

function M.CompileMarkdown()
  local filename = vim.fn.expand('%')
  local output = vim.fn.expand('%:r') .. '.pdf'
  vim.fn.jobstart({ 'pandoc', filename, '-o', output }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("✔ Markdown to PDF conversion finished successfully.")
      else
        vim.notify("✘ Conversion failed.", vim.log.levels.ERROR)
      end
    end,
  })
end

-- === Autocommands ===

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Gruppe für LaTeX Auto-Compile
local tex_group = augroup("LaTeXCompile", {})
autocmd("BufWritePost", {
  group = tex_group,
  pattern = "*.tex",
  callback = M.CompileLatex,
})

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

-- Typst-Dateien automatisch kompilieren
autocmd("BufWritePost", {
  group = augroup("TypstCompile", {}),
  pattern = "*.typ",
  callback = function()
    vim.fn.jobstart({
      "typst", "compile",
      vim.fn.expand("%"),
      vim.fn.expand("%:r") .. ".pdf"
    }, {
      stdout_buffered = true,
      stderr_buffered = true,
    })
  end,
})

-- Wrap + linebreak nur in bestimmten Dateitypen aktivieren
autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function()
    local md_path = vim.fn.expand("%:p")             -- voller Pfad zur .md-Datei
    local pdf_path = md_path:gsub("%.md$", ".pdf")   -- ersetze .md mit .pdf

    if vim.fn.filereadable(pdf_path) == 1 then
      M.CompileMarkdown()
    end
  end,
})

-- Weitere nützliche Einstellungen für Textdateien
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "txt", "md" },
  callback = function()
    vim.opt.wrap = true
    vim.opt.linebreak = true
    vim.opt.breakindent = true
    vim.opt.showbreak = "↪ "
    vim.opt.textwidth = 80      -- Maximale Zeilenlänge
    vim.opt.colorcolumn = "80"  -- Visuelle Linie bei 80 Zeichen
    vim.keymap.set("n", "j", "gj", { noremap = true })
    vim.keymap.set("n", "k", "gk", { noremap = true })
  end
})

-- Automatisches Update von lazy.nvim beim Start
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("lazy").update({ show = false })
  end,
})

return M

