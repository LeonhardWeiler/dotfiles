return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

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

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterStart", {}),
      callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not pcall(vim.treesitter.start, buf, lang) then
          return
        end
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    local incr = { stack = {} }

    local function same_range(a, b)
      local a1, a2, a3, a4 = a:range()
      local b1, b2, b3, b4 = b:range()
      return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
    end

    local function visual_select(node)
      local srow, scol, erow, ecol = node:range()
      if ecol == 0 then
        erow = erow - 1
        ecol = #(vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or "")
      end
      vim.fn.setpos("'<", { 0, srow + 1, scol + 1, 0 })
      vim.fn.setpos("'>", { 0, erow + 1, ecol, 0 })
      vim.cmd("normal! gv")
    end

    local function init_selection()
      local node = vim.treesitter.get_node()
      if not node then
        return
      end
      incr.stack = { node }
      visual_select(node)
    end

    local function increment()
      local stack = incr.stack
      if not stack or #stack == 0 then
        return init_selection()
      end
      local node = stack[#stack]
      local parent = node:parent()
      while parent and same_range(parent, node) do
        parent = parent:parent()
      end
      if parent then
        table.insert(stack, parent)
        visual_select(parent)
      else
        visual_select(node)
      end
    end

    local function decrement()
      local stack = incr.stack
      if not stack or #stack <= 1 then
        return
      end
      table.remove(stack)
      visual_select(stack[#stack])
    end

    vim.keymap.set("n", "<C-space>", init_selection, { desc = "TS-Auswahl starten" })
    vim.keymap.set("x", "<C-space>", increment, { desc = "TS-Auswahl erweitern" })
    vim.keymap.set("x", "<BS>", decrement, { desc = "TS-Auswahl verkleinern" })
  end,
}
