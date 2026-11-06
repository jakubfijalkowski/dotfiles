vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")

-- ui2: the native (experimental) message + cmdline UI. No "Press ENTER"
-- prompts, highlighted cmdline, and vim.notify() lands in the message area
-- (replaces nvim-notify).
require("vim._core.ui2").enable({})

vim.o.clipboard = "unnamedplus"
vim.o.startofline = true
vim.o.title = true
vim.o.scrolloff = 4
vim.o.exrc = true
vim.o.mouse = "a"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.autowrite = true
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded" -- rounded borders for all floats (hover, blink, diagnostics)

vim.opt.wildignore = { ".git", "*.lock.json" }
-- Keep Neovim's defaults (internal diff, linematch, inline:char, ...) and only
-- add vertical splits.
vim.opt.diffopt:append("vertical")

vim.o.ignorecase = true
vim.opt.tags = { "tags;/", "codex.tags;/" }

-- Swap, backup and undo files use Neovim's defaults under stdpath("state"),
-- whose trailing `//` keeps same-named files (mod.rs, init.lua) apart.
