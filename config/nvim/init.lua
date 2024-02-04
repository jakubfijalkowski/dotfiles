require("overrides")
require("load_lazy")

require("lazy").setup {
  { "nvim-lua/plenary.nvim" },
  { "ellisonleao/gruvbox.nvim",       lazy = false, },

  { "airblade/vim-gitgutter" },
  { "easymotion/vim-easymotion" },
  { "folke/neodev.nvim" },
  { "folke/which-key.nvim" },
  { "godlygeek/tabular" },
  { "mbbill/undotree" },
  { "nathanaelkane/vim-indent-guides" },
  { "nvim-lualine/lualine.nvim",      dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-telescope/telescope.nvim",  dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-tree/nvim-web-devicons" },
  { "preservim/nerdcommenter" },
  { "tpope/vim-repeat" },
  { "tpope/vim-surround" },
  { "nvim-tree/nvim-tree.lua" },
  { "mhinz/vim-startify" },
  { "airblade/vim-rooter" },
  { "famiu/bufdelete.nvim" },
  { "rcarriga/nvim-notify" },

  { "neoclide/coc.nvim",              build = "npm ci",                                branch = "master", },
  { "neoclide/coc-json",              build = "npm install" },
  { "neoclide/coc-pairs",             build = "yarn install --frozen-lockfile" },
  { "neoclide/coc-snippets",          build = "yarn install --frozen-lockfile" },
  { "neoclide/coc-yaml",              build = "npm install" },
  { "neoclide/coc-yank",              build = "yarn install --frozen-lockfile" },
  { "josa42/coc-lua",                 build = "npm ci" },
  { "fannheyward/coc-rust-analyzer",  build = "npm ci" },
  { "fannheyward/telescope-coc.nvim" },
}

require("globals")
require("editor")
require("layout")
require("coc_config")
require("keymaps")
