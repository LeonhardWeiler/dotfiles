return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    config = function()
      -- Completion-Capabilities aus blink.cmp an alle LSP-Server weitergeben
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      -- Installierte Server werden automatisch aktiviert (automatic_enable).
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })

      -- Buffer-lokale LSP-Keymaps, sobald ein Server attached ist
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
          vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
        end,
      })
    end,
  },
}

