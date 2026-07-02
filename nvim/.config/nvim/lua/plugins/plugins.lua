return {
  -- UI & UX
  { "echasnovski/mini.pairs", version = false, event = "InsertEnter", opts = {} },
  { "numToStr/Comment.nvim", config = function() require("Comment").setup() end },
  { "nvim-tree/nvim-web-devicons" },
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "chomosuke/typst-preview.nvim", opts = {} }
}

