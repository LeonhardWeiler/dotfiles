-- Leader
vim.g.mapleader = " "

-- Datei-Browser
vim.keymap.set("n", "<leader>pv", vim.cmd.Oil)

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Cursor zentriert halten bei Scroll & Search
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Replace ohne Register zu überschreiben
vim.keymap.set("x", "<leader>r", "\"_dp")

-- Yank in System-Clipboard
vim.keymap.set('n','y','"+y')
vim.keymap.set('n','yy','"+yy')
vim.keymap.set('n','Y','"+Y')
vim.keymap.set('x','y','"+y')
vim.keymap.set('x','Y','"+Y')

-- Suche und Ersetze aktuellem Wort
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Unbind Tasten
vim.keymap.set("n", "<Backspace>", "<Nop>")
vim.keymap.set("n", "<F1>", "<Nop>")
vim.keymap.set("n", "<Space>", "<Nop>")

-- 🧪 Eigene Funktionen
local autocmds = require("config.autocmds")
vim.keymap.set("n", "<leader>ob", autocmds.OpenBrowser, { noremap = true, silent = true })

