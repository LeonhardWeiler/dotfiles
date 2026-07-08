-- C#/Unity: Roslyn Language Server (Microsoft.CodeAnalysis.LanguageServer).
-- Der Server selbst wird als mason-Paket "roslyn" installiert (siehe
-- mason-tools.lua); roslyn.nvim findet die mason-Installation automatisch und
-- erkennt das passende .sln/.csproj (Unity legt diese im Projekt-Root an).
return {
  "seblyng/roslyn.nvim",
  ft = "cs",
  ---@module "roslyn.config"
  ---@type RoslynNvimConfig
  opts = {
    -- Dateiüberwachung dem Server überlassen (robuster bei großen
    -- Unity-Projekten mit vielen generierten Dateien).
    filewatching = "roslyn",
  },
  config = function(_, opts)
    -- LSP-Einstellungen; Capabilities (blink.cmp) kommen aus der globalen
    -- "*"-Config in lsp.lua. Konfiguration vor dem Server-Start setzen.
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
