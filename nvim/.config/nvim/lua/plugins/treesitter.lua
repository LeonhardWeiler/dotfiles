-- nvim-treesitter auf dem main-Branch (master ist seit 2025 eingefroren und
-- ABI-inkompatibel zur Treesitter-Core von Neovim 0.11+/0.12). Der main-Branch
-- unterstützt kein Lazy-Loading und nutzt eine neue API: install() statt
-- ensure_installed, Highlighting per vim.treesitter.start() im FileType-Autocmd.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    -- Nur benötigte Parser installieren (install() überspringt bereits
    -- vorhandene und baut fehlende bei Bedarf).
    require("nvim-treesitter").install({
      "bash",
      "css",
      "diff",
      "git_config",
      "gitcommit",
      "go",
      "gomod",
      "gosum",
      "html",
      "javascript",
      "json",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "tsx",
      "typescript",
      "typst",
      "vim",
      "vimdoc",
    })

    -- Highlight + treesitter-basierte Faltung/Einrückung pro Buffer aktivieren.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterStart", {}),
      callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype
        -- Nur starten, wenn für den Filetype ein Parser verfügbar ist.
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not pcall(vim.treesitter.start, buf, lang) then
          return
        end
        -- Experimentelle, treesitter-basierte Einrückung.
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
