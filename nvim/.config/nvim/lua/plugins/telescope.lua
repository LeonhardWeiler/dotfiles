return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require('telescope.builtin')

    -- Keymaps
    vim.keymap.set('n', '<leader>sf', function()
      builtin.find_files({ hidden = true, no_ignore = true })
    end, { desc = "Find files (inkl. hidden)" })

    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = "Help tags" })
    vim.keymap.set('n', '<leader>sc', builtin.colorscheme, { desc = "Colorscheme" })
    vim.keymap.set('n', '<leader>sq', builtin.quickfix, { desc = "Quickfix list" })
    vim.keymap.set('n', '<leader>sl', builtin.spell_suggest, { desc = "Spell suggestions" })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = "Keymaps" })
    vim.keymap.set('n', '<leader>st', builtin.filetypes, { desc = "Filetypes" })
  end
}

