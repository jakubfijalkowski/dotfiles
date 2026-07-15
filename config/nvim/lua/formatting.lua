require("conform").setup({
  formatters_by_ft = {
    -- Requires the stylua binary: run `:MasonInstall stylua` once, or install it
    -- via your system package manager (conform finds it on $PATH).
    lua = { "stylua" },
    -- Every other filetype falls back to LSP formatting (rust-analyzer,
    -- terraform-ls, yaml-language-server, ...).
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
})
