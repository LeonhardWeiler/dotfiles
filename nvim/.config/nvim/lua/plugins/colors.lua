return {
  "rebelot/kanagawa.nvim",
  config = function()
    require("kanagawa").setup({
      compile = true,
      functionStyle = { italic = true },
      background = {
        dark = "dragon"
      },
      palette = {
        roninYellow = "#FFA066",
      },
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none"
            }
          }
        }
      }
    })
  end,
}

