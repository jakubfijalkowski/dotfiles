-- Status line plugin
require("lualine").setup({
  options = {
    theme = "gruvbox",
    globalstatus = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      "branch",
      -- Feed the diff component from gitsigns' cached status dict instead of
      -- shelling out to `git diff` on every redraw.
      {
        "diff",
        source = function()
          local gs = vim.b.gitsigns_status_dict
          if gs then
            return { added = gs.added, modified = gs.changed, removed = gs.removed }
          end
        end,
      },
    },
    lualine_c = { "filename" },
    -- Attached LSP clients with a spinner while they report progress.
    lualine_x = { "lsp_status", "diagnostics" },
    lualine_y = { "encoding", "fileformat", "filetype" },
    lualine_z = { "progress", "location" },
  },
  tabline = {
    lualine_a = { "buffers" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  extensions = { "nvim-tree" },
})

-- Git signs (hunks in the sign column, staging, blame). Replaces vim-gitgutter.
-- Buffer-local keymaps live in on_attach so they only bind in git-tracked
-- buffers. Leader is `,`; the hunk maps sit under `,h*` and toggles under `,t*`.
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buf = bufnr, silent = true, desc = desc })
    end

    -- Navigation: ]c / [c jump between hunks, falling back to Vim's builtin
    -- diff-mode motions when the buffer is in a diff split.
    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next git hunk")
    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Prev git hunk")

    -- Actions: stage / reset (visual selects a line range), preview, blame.
    map("n", "<Leader>hs", gs.stage_hunk, "Stage hunk")
    map("n", "<Leader>hr", gs.reset_hunk, "Reset hunk")
    map("v", "<Leader>hs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Stage selected lines")
    map("v", "<Leader>hr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Reset selected lines")
    map("n", "<Leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<Leader>hb", function()
      gs.blame_line({ full = true })
    end, "Blame line")

    -- Toggle: inline virtual-text blame on the current line.
    map("n", "<Leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
  end,
})

-- Telescope
local telescope = require("telescope")
telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = require("telescope.actions").close,
      },
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_cursor(),
    },
  },
})
telescope.load_extension("ui-select")

-- Nvim-tree
require("nvim-tree").setup({
  sync_root_with_cwd = true,
  view = {
    width = 50,
  },
  filters = {
    dotfiles = true,
  },
  renderer = {
    highlight_git = "icon",
    highlight_diagnostics = "name",
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
  },
})

-- Start screen (mini.starter, replaces vim-startify): numbered recent files for
-- the cwd and globally. Like startify's change_to_dir, opening a recent file
-- also `:lcd`s into its directory.
local starter = require("mini.starter")
local function lcd_on_open(section)
  return function()
    return vim.tbl_map(function(item)
      local open = item.action
      if type(open) == "function" then
        item.action = function()
          open()
          vim.cmd.lcd(vim.fn.expand("%:p:h"))
        end
      end
      return item
    end, section())
  end
end
starter.setup({
  items = {
    lcd_on_open(starter.sections.recent_files(10, true)),
    lcd_on_open(starter.sections.recent_files(10, false)),
    starter.sections.builtin_actions(),
  },
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.indexing("all", { "Builtin actions" }),
    starter.gen_hook.aligning("center", "center"),
  },
})

-- Undotree: Neovim's built-in :Undotree (opt-in package), toggled by <F10>.
vim.cmd.packadd("nvim.undotree")
vim.o.undofile = true

-- which-key: popup hints for pending keymaps. Individual maps carry their own
-- `desc` (set at each vim.keymap.set call); this spec only labels the leader
-- prefixes so the popup shows readable group names. Uses the v3 spec API
-- (wk.register is deprecated). Inherits the global rounded `winborder`.
require("which-key").setup({
  spec = {
    { "<Leader>f", group = "find/telescope" },
    { "<Leader>fw", group = "workspace" },
    { "<Leader>b", group = "buffer" },
    { "<Leader>c", group = "comment" },
    { "<Leader>q", group = "quickfix" },
    { "<Leader>h", group = "git hunk" },
    { "<Leader>t", group = "toggle" },
  },
})
