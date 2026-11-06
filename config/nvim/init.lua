require("overrides")
require("load_lazy")

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "ellisonleao/gruvbox.nvim", lazy = false },

  -- mini.nvim modules (setup in layout.lua / editor.lua): starter, surround,
  -- align, bufremove. One actively maintained repo replacing vim-startify,
  -- vim-surround + vim-repeat, tabular and bufdelete.nvim.
  { "nvim-mini/mini.nvim", version = "*" },

  { "lewis6991/gitsigns.nvim" },
  { "folke/flash.nvim" },
  { "folke/lazydev.nvim" },
  { "folke/which-key.nvim" },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl" },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-ui-select.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", branch = "main" },

  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },
  { "mason-org/mason-lspconfig.nvim" },
  { "b0o/SchemaStore.nvim" },
  -- blink.cmp v2 is unreleased: track `main` (pinned by lazy-lock.json) and
  -- build the Rust fuzzy matcher locally; prebuilt binaries only ship for tags.
  {
    "saghen/blink.cmp",
    branch = "main",
    version = false,
    dependencies = { "saghen/blink.lib" },
    build = function()
      require("blink.cmp").build():pwait()
    end,
  },
  { "mrcjkb/rustaceanvim", version = "^9", lazy = false },
  { "stevearc/conform.nvim" },
}, {
  -- No plugin here needs luarocks; skip the hererocks setup and its health error.
  rocks = { enabled = false },
})

require("globals")
require("editor")
require("layout")
require("completion")
require("lsp")
require("formatting")
require("keymaps")
