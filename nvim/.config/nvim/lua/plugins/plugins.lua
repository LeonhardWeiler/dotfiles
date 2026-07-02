return {
  -- UI & UX
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
    opts = {},
    -- mini.icons als Ersatz für nvim-web-devicons bereitstellen: Plugins, die
    -- weiterhin require("nvim-web-devicons") aufrufen, bekommen den Mock.
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
