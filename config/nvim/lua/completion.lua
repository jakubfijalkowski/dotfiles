require("blink.cmp").setup({
  -- <Tab> accepts the menu or jumps the snippet placeholder forward,
  -- <S-Tab> jumps it backward.
  keymap = {
    preset = "super-tab",
    ["<CR>"] = { "accept", "fallback" },
    ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
  },

  completion = {
    -- With Enter-to-accept, don't preselect: <CR> then only accepts what you
    -- actively selected, and otherwise inserts a newline.
    list = { selection = { preselect = false } },
    documentation = { auto_show = true },
  },

  signature = { enabled = true },

  -- Snippets use Neovim's native vim.snippet API (blink's default).
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
})
