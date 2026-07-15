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
local telescopeBuiltin = require("telescope.builtin")
vim.keymap.set("n", "<Leader>ff", telescopeBuiltin.find_files)
vim.keymap.set("n", "<Leader>fg", telescopeBuiltin.live_grep)
vim.keymap.set("n", "<Leader>fb", telescopeBuiltin.buffers)

-- LSP pickers. Code actions route through vim.ui.select, which
-- telescope-ui-select renders with Telescope.
vim.keymap.set("n", "<Leader>fa", vim.lsp.buf.code_action)
vim.keymap.set("n", "<Leader>fd", function() telescopeBuiltin.diagnostics({ bufnr = 0 }) end)
vim.keymap.set("n", "<Leader>fr", telescopeBuiltin.lsp_references)
vim.keymap.set("n", "<Leader>fs", telescopeBuiltin.lsp_document_symbols)
vim.keymap.set("n", "<Leader>fws", telescopeBuiltin.lsp_dynamic_workspace_symbols)
vim.keymap.set("n", "<Leader>fwd", telescopeBuiltin.diagnostics)

-- LSP / diagnostics
-- (rename <F2>, code action <F5>, quick-fix <Leader>qf are buffer-local in lsp.lua)
vim.keymap.set("n", "[g", function() vim.diagnostic.jump({ count = -1, float = true }) end, { silent = true })
vim.keymap.set("n", "]g", function() vim.diagnostic.jump({ count = 1, float = true }) end, { silent = true })

vim.keymap.set({ "n", "v" }, "<Leader>=", function()
  require("conform").format({ async = false, lsp_format = "fallback" })
end, { silent = true })

vim.keymap.set("n", "K", function()
  local ft = vim.bo.filetype
  if ft == "vim" or ft == "help" then
    vim.cmd("help " .. vim.fn.expand("<cword>"))
  else
    vim.lsp.buf.hover()
  end
end, { silent = true })

-- NVim Tree
local nvimTree = require("nvim-tree.api")
vim.keymap.set("n", "<F9>", nvimTree.tree.focus)
vim.keymap.set("n", "gr", nvimTree.tree.find_file)

-- Undotree
vim.keymap.set("n", "<F10>", vim.cmd.UndotreeToggle)
