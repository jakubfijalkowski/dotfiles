-- Diagnostics
vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = true,
  severity_sort = true,
  -- Border comes from the global 'winborder'.
  float = {
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

-- Make lua_ls aware of the Neovim runtime and plugin APIs, except in projects
-- that bring their own .luarc.json (e.g. config/hypr with the Hyprland stubs),
-- where Neovim's `vim.*` would only pollute completion.
require("lazydev").setup({
  enabled = function(root_dir)
    return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
  end,
})

-- blink.cmp advertises its completion capabilities to every server on its own
-- (its plugin/ file extends vim.lsp.config("*")), so nothing to do here.

-- Per-server settings, merged on top of nvim-lspconfig's bundled configs.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false },
    },
  },
})

-- JSON and YAML schemas come from SchemaStore.nvim's catalog.
vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      format = { enable = true },
      -- Disable yamlls' own SchemaStore download; SchemaStore.nvim provides it.
      schemaStore = { enable = false, url = "" },
      schemas = vim.tbl_extend("force", require("schemastore").yaml.schemas(), {
        -- Kubernetes only for manifests in the usual directories, not every YAML.
        kubernetes = {
          "**/k8s/**/*.yaml",
          "**/k8s/**/*.yml",
          "**/kubernetes/**/*.yaml",
          "**/kubernetes/**/*.yml",
          "**/manifests/**/*.yaml",
          "**/manifests/**/*.yml",
        },
      }),
    },
  },
})

-- terraform-ls logs verbosely to stderr, which Neovim copies into lsp.log as
-- errors (it grew to 150 MB). Send its own log elsewhere.
vim.lsp.config("terraformls", {
  cmd = { "terraform-ls", "serve", "-log-file=/dev/null" },
})

-- QML (the QuickShell bar). Arch ships the server as qmlls6 with Qt 6; it is a
-- system binary, so enable it directly rather than through mason.
vim.lsp.config("qmlls", {
  cmd = { "qmlls6" },
})
vim.lsp.enable("qmlls")

-- Rust is owned by rustaceanvim, NOT lspconfig/mason. Do NOT also enable
-- rust_analyzer through mason-lspconfig (see automatic_enable.exclude below) or
-- you get two clients. rustaceanvim (>= 8.0.3) merges this native config,
-- registered under its own "rust-analyzer" name, into its server settings.
vim.lsp.config("rust-analyzer", {
  settings = {
    ["rust-analyzer"] = {
      procMacro = { enable = true },
      cargo = { features = "all" },
    },
  },
})

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "jsonls", "yamlls", "terraformls", "bashls", "tombi" },
  automatic_enable = {
    exclude = { "rust_analyzer" },
  },
})

-- Non-LSP tools that mason-lspconfig cannot install: the stylua formatter
-- (conform) and shellcheck (bashls lints through it). Skipped in headless mode,
-- like mason-lspconfig's ensure_installed.
if #vim.api.nvim_list_uis() > 0 then
  local registry = require("mason-registry")
  registry.refresh(function()
    for _, name in ipairs({ "stylua", "shellcheck" }) do
      local pkg = registry.get_package(name)
      if not pkg:is_installed() then
        pkg:install()
      end
    end
  end)
end

-- CodeLens: display lenses (rendered as virtual lines above the code) for
-- servers that provide them, e.g. rust-analyzer. Managed, so it auto-refreshes.
vim.lsp.codelens.enable(true)

-- Buffer-local LSP keymaps, applied when a server attaches. These mirror
-- Neovim's built-in defaults (grn, gra, grx, grr, ...) on old muscle-memory keys.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buf = args.buf, silent = true, desc = desc })
    end

    map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "v" }, "<F5>", vim.lsp.buf.code_action, "Code action")
    -- Same as built-in grx; a no-op on servers without code lenses.
    map("n", "<F4>", vim.lsp.codelens.run, "Run code lens")

    map("n", "<Leader>qf", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "quickfix" } },
      })
    end, "Quick fix")
  end,
})
