vim.o.textwidth = 100
vim.o.colorcolumn = "+1"
vim.o.ruler = true
vim.o.wrap = false

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.shiftround = true
vim.o.autoindent = true
vim.o.expandtab = true

-- Indentation guides (indent-blankline v3). Scope highlighting uses treesitter
-- (set up below). IblIndent derives from Whitespace and IblScope from LineNr, so
-- the guides pick up gruvbox's palette and stay subtle.
require("ibl").setup({
  indent = { char = "▎" },
  scope = {
    show_start = false,
    show_end = false,
  },
  exclude = {
    -- Merged with ibl's defaults (help, checkhealth, TelescopePrompt, ...).
    filetypes = { "help", "NvimTree" },
  },
})

vim.o.foldmethod = "marker"

local indentGroup = vim.api.nvim_create_augroup("IndentOverrides", { clear = true })
local function indent2(ft)
  vim.api.nvim_create_autocmd("FileType", {
    group = indentGroup,
    pattern = ft,
    callback = function()
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
    end,
  })
end

indent2("lua")
indent2("bash")
indent2("zsh")

-- Line numbering
vim.o.number = true
local numberGroup = vim.api.nvim_create_augroup("NumberToggle", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = numberGroup,
  pattern = "*",
  callback = function()
    if vim.o.number then
      vim.o.relativenumber = true
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = numberGroup,
  pattern = "*",
  callback = function()
    if vim.o.number then
      vim.o.relativenumber = false
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = vim.hl.on_yank,
})

-- Tree sitter
--
-- On the nvim-treesitter `main` branch, `.install()` ONLY downloads/compiles the
-- parsers; there is no `.setup({ highlight = ... })`. Highlighting (and treesitter
-- indentation) must be started per-buffer via a FileType autocmd calling native
-- `vim.treesitter.start()`. Neovim already ships ftplugins that do this for its
-- bundled parsers (lua, markdown, ...), so lua worked out of the box, but
-- terraform/rust silently fell back to legacy regex `:syntax` without this.
local ts_langs = { "lua", "terraform", "rust" }
require("nvim-treesitter").install(ts_langs)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
  pattern = ts_langs,
  callback = function(args)
    -- Highlighting. Idempotent: harmless if a built-in ftplugin already started it.
    vim.treesitter.start()
    -- Treesitter-based indentation (experimental on the main branch).
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
