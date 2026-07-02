-- nvim-lint: einziger Linter der Config.
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      javascript = { "biomejs" },
      typescript = { "biomejs" },
      javascriptreact = { "biomejs" },
      typescriptreact = { "biomejs" },
      -- Lua: keine selene-Diagnosen – lua_ls (LSP) liefert die Lua-Diagnosen
      -- bereits sauber. selene ohne Neovim-std würde jeden Buffer mit
      -- falsch-positiven `vim is not defined` fluten.
      go = { "golangcilint" },
      -- Markdown: kein markdownlint – es arbeitet gegen prettierd (bricht
      -- Prosa nicht auf 80 Zeichen um) und erzeugt so Dauer-Diagnosen wie
      -- MD013/line-length. Formatierung uebernimmt prettierd via conform.
    }

    local grp = vim.api.nvim_create_augroup("NvimLint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      group = grp,
      callback = function()
        -- Nur linten, wenn der Buffer eine echte Datei ist.
        if vim.bo.buftype == "" then
          lint.try_lint()
        end
      end,
    })
  end,
}
