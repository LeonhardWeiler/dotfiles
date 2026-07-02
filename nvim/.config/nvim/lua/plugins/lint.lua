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
      lua = { "selene" },
      go = { "golangcilint" },
      markdown = { "markdownlint" },
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
