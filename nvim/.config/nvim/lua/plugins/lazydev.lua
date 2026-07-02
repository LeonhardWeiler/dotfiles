-- lazydev.nvim: konfiguriert lua_ls für die Neovim-Runtime und Plugin-APIs
-- (Ersatz für manuelle library/globals-Bastelei).
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
