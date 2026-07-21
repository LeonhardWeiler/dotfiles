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
      -- prettier, not prettierd: prettierd is a daemon that outlives nvim and
      -- keeps ~60 MB resident forever. biome handles css; html and markdown
      -- have no biome formatter (html is experimental, markdown unsupported),
      -- so those stay on plain prettier, which exits after each run.
      html = { "prettier" },
      css = { "biome" },
      markdown = { "prettier" },
      go = { "goimports", "gofumpt" },
      typst = { "typstyle" },
      cs = { "csharpier" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  },
}
