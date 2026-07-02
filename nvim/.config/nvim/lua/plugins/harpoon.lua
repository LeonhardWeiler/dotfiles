return {
  "ThePrimeagen/harpoon",
  config = function()
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Harpoon: Datei anheften" })
    vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu, { desc = "Harpoon: Menü" })

    -- Sequentielle, kollisionsarme Slots: <leader>1 … <leader>4.
    -- (Ersetzt <C-h>/<C-s>, die Fenster-links bzw. Speichern belegten.)
    for i = 1, 4 do
      vim.keymap.set("n", "<leader>" .. i, function() ui.nav_file(i) end,
        { desc = "Harpoon: Datei " .. i })
    end
  end
}

