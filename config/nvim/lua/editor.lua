vim.o.textwidth = 100
vim.o.colorcolumn = "+1"
vim.o.ruler = true
vim.o.wrap = false

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.shiftround = true
vim.o.autoindent = true
vim.o.expandtab = true

vim.g.indent_guides_guide_size = 1
vim.g.indent_guides_enable_on_vim_startup = 1
vim.g.indent_guides_exclude_filetypes = { "help", "NvimTree" }
vim.g.indent_guides_start_level = 2

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
  end
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = numberGroup,
  pattern = "*",
  callback = function()
    if vim.o.number then
      vim.o.relativenumber = false
    end
  end
})

vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = vim.highlight.on_yank
})

-- Tree sitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "terraform", "rust" },
  sync_install = false,
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = { enable = false },
})
