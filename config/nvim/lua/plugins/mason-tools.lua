return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "mason-org/mason.nvim" },
  opts = {
    ensure_installed = {
      "tree-sitter-cli",
      "stylua",
      "biome",
      "prettier",
      "goimports",
      "gofumpt",
      "typstyle",
      "golangci-lint",
      "roslyn-language-server",
      "csharpier",
    },
  },
}
