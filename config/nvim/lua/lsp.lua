-- Diagnostics
vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  jump = {
    -- `jump.float = true` was deprecated in 0.12; on_jump is the documented
    -- equivalent (open a cursor-scoped, unfocused diagnostic float after jumping).
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "!",
      [vim.diagnostic.severity.WARN] = "?",
      [vim.diagnostic.severity.INFO] = "i",
      [vim.diagnostic.severity.HINT] = "h",
    },
  },
})

-- Make lua_ls aware of the Neovim runtime and plugin APIs.
require("lazydev").setup()

-- Rust is owned by rustaceanvim, NOT lspconfig/mason. Do NOT also enable
-- rust_analyzer through mason-lspconfig (see automatic_enable.exclude below) or
-- you get two clients.
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

-- CodeLens: display lenses (rendered as virtual lines above the code) for
-- servers that provide them, e.g. rust-analyzer. Managed, so it auto-refreshes.
vim.lsp.codelens.enable(true)

-- Buffer-local LSP keymaps, applied when a server attaches.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
    end

    map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "v" }, "<F5>", vim.lsp.buf.code_action, "Code action")

    map("n", "<Leader>qf", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "quickfix" } },
      })
    end, "Quick fix")

    -- Run the code lens under the cursor (only for servers that provide lenses).
    if client and client:supports_method("textDocument/codeLens") then
      map("n", "<F4>", vim.lsp.codelens.run, "Run code lens")
    end
  end,
})
