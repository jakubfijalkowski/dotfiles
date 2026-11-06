require("conform").setup({
  formatters_by_ft = {
    -- stylua is installed by mason (see lsp.lua) and found on mason's $PATH. It
    -- reads config/nvim/.stylua.toml because ~/.config/nvim links the whole dir.
    lua = { "stylua" },
    -- Every other filetype falls back to LSP formatting (rust-analyzer,
    -- terraform-ls, yaml-language-server, ...).
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
})
