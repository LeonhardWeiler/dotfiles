return {
  { "echasnovski/mini.pairs", version = false, event = "InsertEnter", opts = {} },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "echasnovski/mini.icons",
    version = false,
    lazy = true,
    opts = {
      -- Eigenes Icon fuer AGENT-Ordner (KI-/Workflow-Dateien): Roboter-Glyph
      -- (nf-md-robot) in Lila. Greift ueberall, wo mini.icons Directory-Icons
      -- liefert (u. a. oil.nvim).
      directory = {
        AGENT = { glyph = "󰚩", hl = "MiniIconsPurple" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "chomosuke/typst-preview.nvim", opts = {} },
}
