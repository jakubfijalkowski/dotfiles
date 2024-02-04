local helpers = require("helpers")

-- Status line plugin
require("lualine").setup {
  options = {
    theme = "gruvbox",
    globalstatus = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff" },
    lualine_c = { "filename" },
    lualine_x = { "diagnostics" },
    lualine_y = { "encoding", "fileformat", "filetype" },
    lualine_z = { "progress", "location" }
  },
  tabline = {
    lualine_a = { "buffers" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  extensions = { "nvim-tree" }
}

-- Telescope
local telescope = require("telescope")
telescope.setup {
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = require("telescope.actions").close
      }
    }
  },
  extensions = {
    coc = {
      theme = "cursor",
      prefer_locations = true,
    }
  }
}
telescope.load_extension("coc")

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
  }
})

-- Undotree
vim.g.undotree_WindowLayout = 3
vim.g.undotree_SetFocusWhenToggle = 1
vim.o.undodir = helpers.LocalDataFolder("undos")
vim.o.undofile = true
