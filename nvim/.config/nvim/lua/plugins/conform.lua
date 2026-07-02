-- conform.nvim: einziger Formatter der Config, mit Format-on-Save.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "biome" },
      typescript = { "biome" },
      javascriptreact = { "biome" },
      typescriptreact = { "biome" },
      json = { "biome" },
      html = { "prettierd" },
      css = { "prettierd" },
      markdown = { "prettierd" },
      -- goimports (Import-Sortierung) vor gofumpt (Formatierung).
      go = { "goimports", "gofumpt" },
      typst = { "typstyle" },
    },
    -- Bei fehlendem Formatter auf LSP-Formatierung zurückfallen.
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  },
}
