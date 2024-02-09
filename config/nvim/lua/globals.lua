local helpers = require("helpers")

vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd.syntax("enable")
vim.cmd.filetype("plugin indent on")
vim.cmd.colorscheme("gruvbox")

vim.o.clipboard = "unnamedplus"
vim.o.encoding = "utf-8"
vim.o.bomb = false
vim.o.showmode = true
vim.o.showcmd = true
vim.o.errorbells = true
vim.o.startofline = true
vim.o.title = true
vim.o.scrolloff = 4
vim.o.hidden = true
vim.o.exrc = true
vim.o.number = true
vim.o.mouse = "a"
vim.o.mousehide = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.signcolumn = "yes"
vim.o.lazyredraw = true

vim.o.wildoptions = "pum"
vim.opt.wildignore = { ".git", "*.lock.json" }
vim.opt.diffopt = { "filler", "vertical" }

vim.o.incsearch = true
vim.o.inccommand = "nosplit"
vim.o.ignorecase = true
vim.o.hlsearch = true
vim.o.gdefault = true

vim.o.directory = helpers.LocalDataFolder("swaps")
vim.o.backupdir = helpers.LocalDataFolder("backups")
vim.opt.tags = { "tags;/", "codex.tags;/" }

vim.notify = require("notify")

vim.g.rooter_manual_only = 1
vim.g.rooter_patterns = { ".git/" }
vim.g.startify_change_to_dir = 1
vim.g.startify_fortune_use_unicode = 1
vim.g.startify_session_persistence = 1
vim.g.terraform_fmt_on_save = 1
