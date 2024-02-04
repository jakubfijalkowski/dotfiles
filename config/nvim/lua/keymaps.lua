-- Easier navigation
vim.keymap.set("", "<C-H>", "<C-W>h")
vim.keymap.set("", "<C-J>", "<C-W>j")
vim.keymap.set("", "<C-K>", "<C-W>k")
vim.keymap.set("", "<C-L>", "<C-W>l")
vim.keymap.set("", "zl", "zL")
vim.keymap.set("", "zh", "zH")

-- Buffer mgmt
vim.keymap.set("n", "<S-Up>", ":resize +1<CR>", { silent = true })
vim.keymap.set("n", "<S-Down>", ":resize -1<CR>", { silent = true })
vim.keymap.set("n", "<S-Left>", ":vertical :resize -1<CR>", { silent = true })
vim.keymap.set("n", "<S-Right>", ":vertical :resize +1<CR>", { silent = true })

vim.keymap.set("n", "<C-p>", ":bprev<CR>", { silent = true })
vim.keymap.set("n", "<C-n>", ":bnext<CR>", { silent = true })

vim.keymap.set("n", "<Leader>bd", function() require("bufdelete").bufdelete(0) end)

-- Easymotion
vim.g.EasyMotion_do_mapping = 0
vim.keymap.set("", "s", "<Plug>(easymotion-bd-f)")
vim.keymap.set("n", "s", "<Plug>(easymotion-overwin-f)")

-- Telescope
local telescope = require("telescope")
local telescopeBuiltin = require("telescope.builtin")
vim.keymap.set("n", "<Leader>ff", telescopeBuiltin.find_files)
vim.keymap.set("n", "<Leader>fg", telescopeBuiltin.live_grep)
vim.keymap.set("n", "<Leader>fb", telescopeBuiltin.buffers)

vim.keymap.set("n", "<Leader>fa", telescope.extensions.coc.code_actions)
vim.keymap.set("n", "<Leader>fd", telescope.extensions.coc.diagnostics)
vim.keymap.set("n", "<Leader>fr", telescope.extensions.coc.references)
vim.keymap.set("n", "<Leader>fs", telescope.extensions.coc.document_symbols)
vim.keymap.set("n", "<Leader>fws", telescope.extensions.coc.workspace_symbols)
vim.keymap.set("n", "<Leader>fwd", telescope.extensions.coc.workspace_diagnostics)

-- Coc
vim.keymap.set("n", "<F2>", "<Plug>(coc-rename)", { silent = true })
vim.keymap.set("n", "<F4>", "<Plug>(coc-codelens-action)", { silent = true })
vim.keymap.set("v", "<F5>", "<Plug>(coc-codeaction-selected)", { silent = true })
vim.keymap.set("n", "<F5>", "<Plug>(coc-codeaction-selected)l", { silent = true })
vim.keymap.set("i", "<F5>", function() vim.fn.CocActionAsync("codeAction", "char") end)

vim.keymap.set("n", "<Leader>=", "<Plug>(coc-format)", { silent = true })
vim.keymap.set("n", "<Leader>qf", "<Plug>(coc-fix-current)", { silent = true })

vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

vim.keymap.set("i", "<C-Space>", "coc#refresh()", { silent = true, expr = true })

vim.keymap.set("i", "<Tab>",
  [[coc#pum#visible() ? coc#pum#next(1): v:lua.coc_check_backspace() ? "\<Tab>" : coc#refresh()]],
  { silent = true, expr = true })
vim.keymap.set("i", "<S-Tab>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], { silent = true, expr = true })
vim.keymap.set("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
  { silent = true, expr = true })

vim.keymap.set("n", "K", _G.coc_show_docs, { silent = true })

-- NVim Tree
local nvimTree = require("nvim-tree.api")
vim.keymap.set("n", "<F9>", nvimTree.tree.focus)
vim.keymap.set("n", "gr", nvimTree.tree.find_file)

-- Undotree
vim.keymap.set("n", "<F10>", vim.cmd.UndotreeToggle)
