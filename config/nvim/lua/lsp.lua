-- Diagnostics (translated from the old coc-settings.json)
vim.diagnostic.config({
  virtual_text = false,    -- diagnostic.virtualText = false
  update_in_insert = true, -- diagnostic.refreshOnInsertMode = true
  severity_sort = true,
  float = {                -- diagnostic.messageTarget = "float"
    border = "rounded",
    source = true,
  },
  jump = {
    float = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "!", -- diagnostic.errorSign = "!"
      [vim.diagnostic.severity.WARN] = "?",
      [vim.diagnostic.severity.INFO] = "i",
      [vim.diagnostic.severity.HINT] = "h",
    },
  },
})

-- Make lua_ls aware of the Neovim runtime and plugin APIs. Replaces the manual
-- Lua.workspace.library wiring that used to live in coc_config.lua (and the
-- never-initialised neodev.nvim).
require("lazydev").setup()

-- Rust is owned by rustaceanvim, NOT lspconfig/mason. The rust-analyzer settings
-- moved here from coc-settings.json. Do NOT also enable rust_analyzer through
-- mason-lspconfig (see automatic_enable.exclude below) or you get two clients.
vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        procMacro = { enable = true },
        cargo = { features = "all" },
      },
    },
  },
}

-- Advertise blink.cmp's completion capabilities to every server.
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- Per-server settings, merged on top of nvim-lspconfig's bundled configs.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      format = { enable = true },
      schemas = {
        kubernetes = { "*.yaml", "*.yml" },
      },
    },
  },
})

-- jsonls and terraformls use nvim-lspconfig's defaults as-is.

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "jsonls", "yamlls", "terraformls" },
  automatic_enable = {
    exclude = { "rust_analyzer" },
  },
})

-- Buffer-local LSP keymaps, applied when a server attaches.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }

    vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<F5>", vim.lsp.buf.code_action, opts)

    vim.keymap.set("n", "<Leader>qf", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "quickfix" } },
      })
    end, opts)
  end,
})
