-- Easier navigation
vim.keymap.set("", "<C-H>", "<C-W>h", { desc = "Go to left window" })
vim.keymap.set("", "<C-J>", "<C-W>j", { desc = "Go to lower window" })
vim.keymap.set("", "<C-K>", "<C-W>k", { desc = "Go to upper window" })
vim.keymap.set("", "<C-L>", "<C-W>l", { desc = "Go to right window" })
vim.keymap.set("", "zl", "zL", { desc = "Scroll half screen right" })
vim.keymap.set("", "zh", "zH", { desc = "Scroll half screen left" })

-- Buffer mgmt
vim.keymap.set("n", "<S-Up>", ":resize +1<CR>", { silent = true, desc = "Increase window height" })
vim.keymap.set(
  "n",
  "<S-Down>",
  ":resize -1<CR>",
  { silent = true, desc = "Decrease window height" }
)
vim.keymap.set(
  "n",
  "<S-Left>",
  ":vertical :resize -1<CR>",
  { silent = true, desc = "Decrease window width" }
)
vim.keymap.set(
  "n",
  "<S-Right>",
  ":vertical :resize +1<CR>",
  { silent = true, desc = "Increase window width" }
)

vim.keymap.set("n", "<C-p>", ":bprev<CR>", { silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<C-n>", ":bnext<CR>", { silent = true, desc = "Next buffer" })

vim.keymap.set("n", "<Leader>bd", function()
  require("bufdelete").bufdelete(0)
end, { desc = "Delete buffer" })

-- Commenting: native gc/gcc (see :help commenting). These shims preserve
-- nerdcommenter's old <Leader>c muscle memory, delegating to the built-in
-- commenting operator (remap = true so gc/gcc resolve to their defaults).
vim.keymap.set("n", "<Leader>c<Space>", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "<Leader>c<Space>", "gc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", "<Leader>cc", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("x", "<Leader>cc", "gc", { remap = true, desc = "Toggle comment" })

-- Flash (motions / jumps) — replaces easymotion.
-- `s` jumps by search label across all visible windows (multi_window = true),
-- preserving the old easymotion-overwin `s`. `S` selects a Treesitter node
-- (overrides native `S` == `cc`; use `cc` for that). Native `f/F/t/T` are left
-- untouched — char mode is disabled to keep the change unobtrusive.
local flash = require("flash")
flash.setup({
  modes = { char = { enabled = false } },
})
vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", flash.remote, { desc = "Flash remote" })
vim.keymap.set("c", "<C-s>", flash.toggle, { desc = "Toggle Flash search" })

-- Telescope
local telescopeBuiltin = require("telescope.builtin")
vim.keymap.set("n", "<Leader>ff", telescopeBuiltin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<Leader>fg", telescopeBuiltin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<Leader>fb", telescopeBuiltin.buffers, { desc = "Find buffers" })

-- LSP pickers. Code actions route through vim.ui.select, which
-- telescope-ui-select renders with Telescope.
vim.keymap.set("n", "<Leader>fa", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<Leader>fd", function()
  telescopeBuiltin.diagnostics({ bufnr = 0 })
end, { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<Leader>fr", telescopeBuiltin.lsp_references, { desc = "LSP references" })
vim.keymap.set(
  "n",
  "<Leader>fs",
  telescopeBuiltin.lsp_document_symbols,
  { desc = "Document symbols" }
)
vim.keymap.set(
  "n",
  "<Leader>fws",
  telescopeBuiltin.lsp_dynamic_workspace_symbols,
  { desc = "Workspace symbols" }
)
vim.keymap.set("n", "<Leader>fwd", telescopeBuiltin.diagnostics, { desc = "Workspace diagnostics" })

-- LSP / diagnostics
-- (rename <F2>, code action <F5>, quick-fix <Leader>qf are buffer-local in lsp.lua)
vim.keymap.set("n", "[g", function()
  vim.diagnostic.jump({ count = -1 })
end, { silent = true, desc = "Previous diagnostic" })
vim.keymap.set("n", "]g", function()
  vim.diagnostic.jump({ count = 1 })
end, { silent = true, desc = "Next diagnostic" })

vim.keymap.set({ "n", "v" }, "<Leader>=", function()
  require("conform").format({ async = false, lsp_format = "fallback" })
end, { silent = true, desc = "Format buffer" })

vim.keymap.set("n", "K", function()
  local ft = vim.bo.filetype
  if ft == "vim" or ft == "help" then
    vim.cmd("help " .. vim.fn.expand("<cword>"))
  else
    vim.lsp.buf.hover()
  end
end, { silent = true, desc = "Hover / help" })

-- NVim Tree
local nvimTree = require("nvim-tree.api")
vim.keymap.set("n", "<F9>", nvimTree.tree.focus, { desc = "Focus file tree" })
vim.keymap.set("n", "gr", nvimTree.tree.find_file, { desc = "Reveal file in tree" })

-- Undotree
vim.keymap.set("n", "<F10>", vim.cmd.UndotreeToggle, { desc = "Toggle undotree" })
