vim.o.textwidth = 100
vim.o.colorcolumn = "+1"
vim.o.wrap = false

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.shiftround = true
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
    filetypes = { "help", "NvimTree", "ministarter" },
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

-- Wrapped on purpose: passing vim.hl.on_yank directly hands it the autocmd
-- args, whose `event` string shadows v:event and silently disables the flash.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Surround (mini.surround) with vim-surround's keys: ys{motion}{char},
-- yss{char}, ds{char}, cs{old}{new}. Dot-repeat works natively (no vim-repeat).
-- Visual `S` belongs to flash, so visual surround stays on vim-surround's `gS`.
require("mini.surround").setup({
  mappings = {
    add = "ys",
    delete = "ds",
    find = "",
    find_left = "",
    highlight = "",
    replace = "cs",
    suffix_last = "",
    suffix_next = "",
  },
  search_method = "cover_or_next",
})
vim.keymap.del("x", "ys")
vim.keymap.set("x", "gS", [[:<C-u>lua MiniSurround.add('visual')<CR>]], {
  silent = true,
  desc = "Surround selection",
})
vim.keymap.set("n", "yss", "ys_", { remap = true, desc = "Surround line" })

-- Alignment (mini.align, replaces tabular): `ga{motion}` / visual `ga`, then
-- the split character, e.g. `gaip=`. `gA` previews interactively.
require("mini.align").setup()

-- Tree sitter
--
-- On the nvim-treesitter `main` branch, `.install()` ONLY downloads/compiles the
-- parsers; there is no `.setup({ highlight = ... })`. Highlighting has to be
-- started per buffer with native `vim.treesitter.start()`.
local ts_langs = {
  "bash",
  "diff",
  "git_rebase",
  "gitcommit",
  "hyprlang",
  "json",
  "just",
  "lua",
  "qmljs",
  "regex",
  "rust",
  "terraform",
  "toml",
  "yaml",
  "zsh",
}
require("nvim-treesitter").install(ts_langs)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
  callback = function(args)
    -- Highlight every filetype that has a parser (installed above or bundled
    -- with Neovim). Fails harmlessly when there is none; idempotent when a
    -- built-in ftplugin already started it.
    if not pcall(vim.treesitter.start, args.buf) then
      return
    end
    -- Treesitter indentation (experimental on the main branch), limited to the
    -- languages installed above that ship an indents query.
    local lang = vim.treesitter.language.get_lang(args.match)
    if lang and vim.list_contains(ts_langs, lang) and vim.treesitter.query.get(lang, "indents") then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
