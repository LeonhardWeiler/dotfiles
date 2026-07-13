local M = {}

function M.OpenBrowser()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("📛 No file path for the current buffer", vim.log.levels.WARN)
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
  callback = function(args)
    -- buffer-local, so wrap/linebreak/spell and the gj/gk maps don't leak into other buffers
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    -- Spell check only when writing prose (<leader>sl then offers suggestions)
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en,de"
    vim.keymap.set("n", "j", "gj", { noremap = true, buffer = args.buf })
    vim.keymap.set("n", "k", "gk", { noremap = true, buffer = args.buf })
  end,
})

-- On save in prose buffers (spell active), automatically capitalize words that
-- Vim marks as a pure capitalization error ("caps") — i.e. typical sentence
-- starts where only the first letter changes from lower to upper case. Real
-- typos (type "bad"/"rare"/"local") are deliberately NOT auto-corrected.
--
-- The basis is `spellbadword({string})`: it respects 'spellcapcheck', returns
-- the first bad word plus its type and treats the start of the passed string as
-- a sentence *continuation*. The whole buffer is checked as one "\n"-joined
-- string: sentence starts after ".", "!", "?" + space are recognized as "caps"
-- and capitalized, while a continued sentence is correctly NOT. This is
-- deliberately conservative (never a false capitalization).
-- Limit: a sentence start directly after a *hard* line break (".\n") is not
-- recognized — with soft-wrap prose (long lines) that is the normal case and it
-- works; if you hard-wrap sentences you have to capitalize the line start yourself.
function M.autocapitalize_on_save()
  if not vim.wo.spell or not vim.bo.modifiable then
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local view = vim.fn.winsaveview()
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")

  local edits = {} -- { { s, e, rep }, ... } with 0-based byte offsets in `text`
  local from = 1 -- 1-based Lua index to keep searching from
  while from <= #text do
    local sub = string.sub(text, from)
    local bad = vim.fn.spellbadword(sub) -- { word, type }
    local word = bad[1]
    if word == "" then
      break
    end
    -- Position of the found word (with word boundaries, \V = everything literal).
    local mp = vim.fn.matchstrpos(sub, [[\V\<]] .. vim.fn.escape(word, [[\]]) .. [[\>]])
    local ms, me = mp[2], mp[3] -- 0-based bytes in `sub`
    if ms < 0 then
      local f = string.find(sub, word, 1, true)
      if not f then
        break
      end
      ms, me = f - 1, f - 1 + #word
    end
    if bad[2] == "caps" then
      local first = vim.fn.strcharpart(word, 0, 1)
      local upper = vim.fn.toupper(first)
      if upper ~= first then -- only a real lower -> upper change of the 1st letter
        local abs = from - 1 -- 0-based offset of `sub` in `text`
        edits[#edits + 1] = { s = abs + ms, e = abs + me, rep = upper .. string.sub(word, #first + 1) }
      end
    end
    from = from + me -- keep searching past the word (guarantees progress)
  end

  if #edits > 0 then
    local parts, cur = {}, 0
    for _, ed in ipairs(edits) do
      parts[#parts + 1] = string.sub(text, cur + 1, ed.s)
      parts[#parts + 1] = ed.rep
      cur = ed.e
    end
    parts[#parts + 1] = string.sub(text, cur + 1)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(table.concat(parts), "\n", { plain = true }))
    vim.fn.winrestview(view)
  end
end

autocmd("BufWritePre", {
  group = augroup("SpellAutocapitalize", {}),
  pattern = "*",
  callback = function()
    M.autocapitalize_on_save()
  end,
})

return M
