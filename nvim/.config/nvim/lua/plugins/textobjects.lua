-- Treesitter-Textobjects (main-Branch, passend zum nvim-treesitter-main-Branch).
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local sel = function(obj)
      return function()
        select.select_textobject(obj, "textobjects")
      end
    end
    -- Select in Operator- und Visual-Mode
    for _, m in ipairs({ "x", "o" }) do
      vim.keymap.set(m, "af", sel("@function.outer"), { desc = "a function" })
      vim.keymap.set(m, "if", sel("@function.inner"), { desc = "inner function" })
      vim.keymap.set(m, "ac", sel("@class.outer"), { desc = "a class" })
      vim.keymap.set(m, "ic", sel("@class.inner"), { desc = "inner class" })
      vim.keymap.set(m, "aa", sel("@parameter.outer"), { desc = "a parameter" })
      vim.keymap.set(m, "ia", sel("@parameter.inner"), { desc = "inner parameter" })
    end

    -- Bewegung zwischen Funktionen/Klassen
    local move = require("nvim-treesitter-textobjects.move")
    local goto_map = {
      ["]f"] = { move.goto_next_start, "@function.outer", "Nächste Funktion" },
      ["]c"] = { move.goto_next_start, "@class.outer", "Nächste Klasse" },
      ["[f"] = { move.goto_previous_start, "@function.outer", "Vorige Funktion" },
      ["[c"] = { move.goto_previous_start, "@class.outer", "Vorige Klasse" },
    }
    for key, spec in pairs(goto_map) do
      vim.keymap.set({ "n", "x", "o" }, key, function()
        spec[1](spec[2], "textobjects")
      end, { desc = spec[3] })
    end
  end,
}
