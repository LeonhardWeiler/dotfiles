return {
  -- UI & UX
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "numToStr/Comment.nvim", config = function() require("Comment").setup() end },
  { "nvim-tree/nvim-web-devicons" },
  { "github/copilot.vim" },
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "chomosuke/typst-preview.nvim", opts = {} }
}

