return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "mason-org/mason.nvim" },
  opts = {
    ensure_installed = {
      "tree-sitter-cli",
      "stylua",
      "biome",
      "prettierd",
      "goimports",
      "gofumpt",
      "typstyle",
      "golangci-lint",
      "roslyn", -- C#-Language-Server (Roslyn), von roslyn.nvim genutzt
      "csharpier", -- C#-Formatter
    },
  },
}
