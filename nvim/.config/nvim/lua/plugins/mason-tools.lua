-- mason-tool-installer installiert Nicht-LSP-Tools automatisch (mason.nvim
-- selbst kann das nicht). Formatter/Linter werden in conform.lua/lint.lua
-- ergänzt; tree-sitter-cli wird vom nvim-treesitter-main-Branch zum
-- Kompilieren der Parser benötigt.
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "mason-org/mason.nvim" },
  opts = {
    ensure_installed = {
      "tree-sitter-cli",
    },
  },
}
