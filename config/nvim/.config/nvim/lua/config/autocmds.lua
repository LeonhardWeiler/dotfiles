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
  callback = function(args)
    -- buffer-lokal, damit wrap/linebreak/spell und die gj/gk-Maps nicht in andere Buffer leaken
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    -- Rechtschreibung nur beim Schreiben von Prosa (<leader>sl liefert dann Vorschlaege)
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en,de"
    vim.keymap.set("n", "j", "gj", { noremap = true, buffer = args.buf })
    vim.keymap.set("n", "k", "gk", { noremap = true, buffer = args.buf })
  end,
})

-- Beim Speichern in Prosa-Buffern (spell aktiv) Woerter automatisch gross-
-- schreiben, wenn Vim sie als reinen Gross-/Kleinschreibungs-Fehler ("caps")
-- markiert – also typische Satzanfaenge, bei denen sich nur der erste Buchstabe
-- von klein zu gross aendert. Echte Tippfehler (Typ "bad"/"rare"/"local")
-- werden bewusst NICHT automatisch korrigiert.
--
-- Grundlage ist `spellbadword({string})`: es respektiert 'spellcapcheck', liefert
-- das erste fehlerhafte Wort samt Typ und behandelt den Anfang der uebergebenen
-- Zeichenkette als Satz-*Fortsetzung*. Der gesamte Buffer wird als eine mit "\n"
-- verbundene Zeichenkette geprueft: Satzanfaenge nach ".", "!", "?" + Leerzeichen
-- werden als "caps" erkannt und grossgeschrieben, ein fortgesetzter Satz dagegen
-- korrekt NICHT. Das ist bewusst konservativ (nie faelschliche Grossschreibung).
-- Grenze: Ein Satzanfang direkt nach einem *harten* Zeilenumbruch (".\n") wird
-- nicht erkannt – bei Soft-Wrap-Prosa (langen Zeilen) ist das der Normalfall und
-- greift; wer Saetze hart umbricht, muss den Zeilenanfang selbst gross schreiben.
function M.autocapitalize_on_save()
  if not vim.wo.spell or not vim.bo.modifiable then
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local view = vim.fn.winsaveview()
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")

  local edits = {} -- { { s, e, rep }, ... } mit 0-basierten Byte-Offsets in `text`
  local from = 1 -- 1-basierter Lua-Index, ab dem weitergesucht wird
  while from <= #text do
    local sub = string.sub(text, from)
    local bad = vim.fn.spellbadword(sub) -- { wort, typ }
    local word = bad[1]
    if word == "" then
      break
    end
    -- Position des gefundenen Wortes (mit Wortgrenzen, \V = alles literal).
    local mp = vim.fn.matchstrpos(sub, [[\V\<]] .. vim.fn.escape(word, [[\]]) .. [[\>]])
    local ms, me = mp[2], mp[3] -- 0-basierte Bytes in `sub`
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
      if upper ~= first then -- nur echte klein -> gross Aenderung des 1. Buchstabens
        local abs = from - 1 -- 0-basierter Offset von `sub` in `text`
        edits[#edits + 1] = { s = abs + ms, e = abs + me, rep = upper .. string.sub(word, #first + 1) }
      end
    end
    from = from + me -- hinter das Wort weitersuchen (garantiert Fortschritt)
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
