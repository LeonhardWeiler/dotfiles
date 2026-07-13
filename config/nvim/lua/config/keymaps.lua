vim.keymap.set("n", "<leader>pv", vim.cmd.Oil)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>r", '"_dp')

-- <leader>S (not <leader>s), so <leader>s… stays collision-free as the Telescope prefix
vim.keymap.set(
  "n",
  "<leader>S",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Search & replace word under cursor" }
)

-- Write diagnostics into the quickfix list (then shown via <leader>sq)
vim.keymap.set("n", "<leader>sd", function()
  vim.diagnostic.setqflist({ open = false })
end, { desc = "Diagnostics → quickfix list" })

vim.keymap.set("n", "<Backspace>", "<Nop>")
vim.keymap.set("n", "<F1>", "<Nop>")
vim.keymap.set("n", "<Space>", "<Nop>")

local autocmds = require("config.autocmds")
vim.keymap.set("n", "<leader>ob", autocmds.OpenBrowser, { noremap = true, silent = true })
