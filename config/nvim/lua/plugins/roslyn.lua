-- C#/Unity: Roslyn Language Server (Microsoft.CodeAnalysis.LanguageServer).
-- The server itself is installed as the mason package "roslyn" (see
-- mason-tools.lua); roslyn.nvim finds the mason installation automatically and
-- detects the matching .sln/.csproj (Unity places these in the project root).
return {
  "seblyng/roslyn.nvim",
  ft = "cs",
  ---@module "roslyn.config"
  ---@type RoslynNvimConfig
  opts = {
    -- Let the server handle file watching (more robust for large Unity
    -- projects with many generated files).
    filewatching = "roslyn",
  },
  config = function(_, opts)
    -- LSP settings; capabilities (blink.cmp) come from the global "*" config in
    -- lsp.lua. Set the configuration before the server starts.
    vim.lsp.config("roslyn", {
      settings = {
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          csharp_enable_inlay_hints_for_types = true,
          dotnet_enable_inlay_hints_for_indexer_parameters = true,
          dotnet_enable_inlay_hints_for_literal_parameters = true,
          dotnet_enable_inlay_hints_for_object_creation_parameters = true,
          dotnet_enable_inlay_hints_for_other_parameters = true,
          dotnet_enable_inlay_hints_for_parameters = true,
        },
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
        },
      },
    })

    require("roslyn").setup(opts)
  end,
}
