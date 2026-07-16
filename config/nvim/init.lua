require("overrides")
require("load_lazy")

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "ellisonleao/gruvbox.nvim", lazy = false },

  { "lewis6991/gitsigns.nvim" },
  { "folke/flash.nvim" },
  { "folke/lazydev.nvim" },
  { "folke/which-key.nvim" },
  { "godlygeek/tabular" },
  { "mbbill/undotree" },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl" },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-ui-select.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "tpope/vim-repeat" },
  { "tpope/vim-surround" },
  { "nvim-tree/nvim-tree.lua" },
  { "mhinz/vim-startify" },
  { "famiu/bufdelete.nvim" },
  { "rcarriga/nvim-notify" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", branch = "main" },

  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },
  { "mason-org/mason-lspconfig.nvim" },
  { "saghen/blink.cmp", version = "*" },
  { "mrcjkb/rustaceanvim", version = "^6", lazy = false },
  { "stevearc/conform.nvim" },
})

require("globals")
require("editor")
require("layout")
require("completion")
require("lsp")
require("formatting")
require("keymaps")
